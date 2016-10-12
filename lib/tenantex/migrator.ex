defmodule Tenantex.Migrator do
  import Mix.Ecto, only: [build_repo_priv: 1]
  import Tenantex.Prefix

  @doc """
  Apply migrations to a tenant with given strategy, in given direction.

  A direction can be given, as the third parameter, which defaults to `:up`
  A strategy can be given as an option, and defaults to `:all`

  ## Options

    * `:all` - runs all available if `true`
    * `:step` - runs the specific number of migrations
    * `:to` - runs all until the supplied version is reached
    * `:log` - the level to use for logging. Defaults to `:info`.
      Can be any of `Logger.level/0` values or `false`.

  """
  def migrate_tenant(repo, tenant, direction \\ :up, opts \\ []) do
    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :all, true)

    migrate_and_return_status(repo, tenant, direction, opts)
  end


  def tenant_migrations_path(repo) do
    Path.join(build_repo_priv(repo), "tenant_migrations")
  end

  defp migrate_and_return_status(repo, tenant, direction, opts) do
    schema = schema_name(tenant)

    {status, versions} = handle_database_exceptions fn ->
      opts_with_prefix = Keyword.put(opts, :prefix, schema)
      Ecto.Migrator.run(
        repo,
        tenant_migrations_path(repo),
        direction,
        opts_with_prefix
      )
    end

    {status, schema, versions}
  end

  defp handle_database_exceptions(fun) do
    try do
      {:ok, fun.()}
    rescue
      e in Postgrex.Error ->
        {:error, Postgrex.Error.message(e)}
      e in Mariaex.Error ->
        {:error, Mariaex.Error.message(e)}
    end
  end
end
