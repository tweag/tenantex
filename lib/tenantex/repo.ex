defmodule Tenantex.Repo do
  import Application, only: [get_env: 2]
  import Tenantex.Prefix
  import Mix.Tenantex

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Ecto.Repo
      alias Tenantex.TenantMissingError

      @repo Keyword.fetch!(opts, :repo)
      @untenanted [Ecto.Migration.SchemaMigration] ++ Keyword.get(opts, :untenanted, [])

      # From Ecto.Repo
      defdelegate __adapter__, to: @repo
      defdelegate __log__(entry), to: @repo
      defdelegate config(), to: @repo
      defdelegate start_link(opts \\ []), to: @repo
      defdelegate stop(pid, timeout \\ 5000), to: @repo
      defdelegate transaction(fun_or_multi, opts \\ []), to: @repo
      defdelegate in_transaction?(), to: @repo
      defdelegate rollback(value), to: @repo
      defdelegate load(schema_or_types, data), to: @repo

      # From Ecto.Adapters.SQL
      defdelegate __pool__, to: @repo
      defdelegate __sql__, to: @repo

      def all(queryable, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.all(queryable, coerce_prefix(opts))
      end

      def stream(queryable, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.stream(queryable, coerce_prefix(opts))
      end

      def get(queryable, id, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.get(queryable, id, coerce_prefix(opts))
      end

      def get!(queryable, id, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.get!(queryable, id, coerce_prefix(opts))
      end

      def get_by(queryable, clauses, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.get_by(queryable, clauses, coerce_prefix(opts))
      end

      def get_by!(queryable, clauses, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.get_by!(queryable, clauses, coerce_prefix(opts))
      end

      def one(queryable, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.one(queryable, coerce_prefix(opts))
      end

      def one!(queryable, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.one!(queryable, coerce_prefix(opts))
      end

      def preload(struct_or_structs, preloads, opts \\ []) do
        assert_tenant(struct_or_structs, opts)
        @repo.preload(struct_or_structs, preloads, coerce_prefix(opts))
      end

      def aggregate(queryable, aggregate, field, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.aggregate(queryable, aggregate, field, coerce_prefix(opts))
      end

      @insert_all_error """
      For insert_all
        - For tenanted tables
            - Your first parameter must be a tuple with the prefix, and the table name
            - OR
            - pass in the 'prefix' value in 'opts'
        - **Note**
            - Your first parameter may not be the string name of the table, because we can't
              check the associated model to see if it requires a tenant.
      """
      def insert_all(schema_or_source, entries, opts \\ [])
      def insert_all({nil, source} = schema_or_source, entries, opts) do
        if requires_tenant?(source) do
          raise TenantMissingError, message: @insert_all_error
        end
        @repo.insert_all(schema_or_source, entries, coerce_prefix(opts))
      end

      def insert_all({_prefix, _source} = schema_or_source, entries, opts), do: @repo.insert_all(schema_or_source, entries, coerce_prefix(opts))
      def insert_all(schema_or_source, entries, opts) when is_binary(schema_or_source), do: raise TenantMissingError, message: @insert_all_error
      def insert_all(schema_or_source, entries, [prefix: prefix] = opts) when is_atom(schema_or_source) and not is_nil(prefix) do
        @repo.insert_all(schema_or_source, entries, coerce_prefix(opts))
      end
      def insert_all(schema_or_source, entries, opts) when is_atom(schema_or_source) do
        if requires_tenant?(schema_or_source) do
          raise TenantMissingError, message: @insert_all_error
        end

        @repo.insert_all(schema_or_source, entries, coerce_prefix(opts))
      end

      def update_all(queryable, updates, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.update_all(queryable, updates, coerce_prefix(opts))
      end

      def delete_all(queryable, opts \\ []) do
        assert_tenant(queryable, opts)
        @repo.delete_all(queryable, coerce_prefix(opts))
      end

      def insert(struct, opts \\ []) do
        assert_tenant(struct, opts)
        @repo.insert(struct, coerce_prefix(opts))
      end

      def update(struct, opts \\ []) do
        assert_tenant(struct, opts)
        @repo.update(struct, coerce_prefix(opts))
      end

      def insert_or_update(changeset, opts \\ []) do
        assert_tenant(changeset, opts)
        @repo.insert_or_update(changeset, coerce_prefix(opts))
      end

      def delete(struct, opts \\ []) do
        assert_tenant(struct, opts)
        @repo.delete(struct, coerce_prefix(opts))
      end

      def insert!(struct, opts \\ []) do
        assert_tenant(struct, opts)
        @repo.insert!(struct, coerce_prefix(opts))
      end

      def update!(struct, opts \\ []) do
        assert_tenant(struct, opts)
        @repo.update!(struct, coerce_prefix(opts))
      end

      def insert_or_update!(changeset, opts \\ []) do
        assert_tenant(changeset, opts)
        @repo.insert_or_update!(changeset, coerce_prefix(opts))
      end

      def delete!(struct, opts \\ []) do
        assert_tenant(struct, opts)
        @repo.delete!(struct, coerce_prefix(opts))
      end

      defp assert_tenant(_, [prefix: prefix]) when not is_nil(prefix), do: nil
      defp assert_tenant(%Ecto.Changeset{} = changeset, opts) do
        assert_tenant(changeset.data, opts)
      end
      defp assert_tenant(%{__meta__: _} = model, _) do
        if requires_tenant?(model) && !has_prefix?(model) do
          raise TenantMissingError, message: "No tenant specified in #{model.__struct__}"
        end
      end
      defp assert_tenant([], _), do: nil
      defp assert_tenant([ %{__meta__: _} = model| _tail], opts), do: assert_tenant(model, opts)

      defp assert_tenant(queryable, _) do
        query = Ecto.Queryable.to_query(queryable)
        if requires_tenant?(query) && !has_prefix?(query) do
          raise TenantMissingError, message: "No tenant specified in #{get_model_from_query(query)}"
        end
      end

      defp coerce_prefix([prefix: prefix]=opts) do
        Keyword.put(opts, :prefix, schema_name(prefix))
      end
      defp coerce_prefix(opts), do: opts

      defp has_prefix?(%{__meta__: _} = model) do
        if Ecto.get_meta(model, :prefix), do: true, else: false
      end


      defp get_model_from_query(%{from: {_, model}}), do: model

      defp requires_tenant?(%{from: {_, model}}), do: not model in @untenanted
      defp requires_tenant?(%{__struct__: model}), do: not model in @untenanted
      defp requires_tenant?(model), do: not model in @untenanted

      defp has_prefix?(%{prefix: nil}), do: false
      defp has_prefix?(%{prefix: _}), do: true
    end
  end

  def new_tenant(tenant) do
    create_schema(tenant)
    Code.compiler_options(ignore_module_conflict: true)

    Ecto.Migrator.run(get_repo(), tenant_migrations_path(get_repo()), :up, [prefix: schema_name(tenant), all: true])
  end

  def create_schema(tenant) do
    schema = schema_name(tenant)
    case get_repo().__adapter__ do
      Ecto.Adapters.Postgres -> Ecto.Adapters.SQL.query(get_repo(), "CREATE SCHEMA \"#{schema}\"", [])
      Ecto.Adapters.MySQL -> Ecto.Adapters.SQL.query(get_repo(), "CREATE DATABASE #{schema}", [])
    end
  end

  def drop_tenant(tenant) do
    schema = schema_name(tenant)
    case get_repo().__adapter__ do
      Ecto.Adapters.Postgres -> Ecto.Adapters.SQL.query(get_repo(), "DROP SCHEMA #{schema} CASCADE", [])
      Ecto.Adapters.MySQL -> Ecto.Adapters.SQL.query(get_repo(), "DROP DATABASE #{schema}", [])
    end
  end

  def list_tenants do
    statement = case get_repo().__adapter__ do
      Ecto.Adapters.Postgres ->
        "SELECT schema_name FROM information_schema.schemata"
      Ecto.Adapters.MySQL ->
        "SHOW DATABASES LIKE '" <> get_prefix() <> "%'"
      Ecto.Adapters.SQL ->
        ""
    end
    get_repo()
    |> Ecto.Adapters.SQL.query!(statement)
    |> Map.fetch!(:rows)
    |> Enum.flat_map(&(&1))
    |> Enum.filter(&(String.starts_with?(&1, get_prefix())))
  end

  defp tenant_exists(tenant) do

  end

  defp get_repo do
    case get_env(:tenantex, Tenantex)[:repo] do
      nil -> default_repo()
      repo -> repo
    end
  end
  
  defp get_appname do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
  end

  defp default_repo do
    get_appname()
    |> get_env(:ecto_repos)
    |> List.first()    
  end

end
