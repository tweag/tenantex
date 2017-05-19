defmodule Tenantex do
  import Application, only: [get_env: 2]

  defmodule TenantMissingError do
    defexception message: "No tenant specified"
  end
  defdelegate drop_tenant(repo, tenant), to: Tenantex.Repo
  defdelegate new_tenant(repo, tenant), to: Tenantex.Repo

  def list_tenants do
    statement = case get_repo_adapter() do
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

  defp get_prefix, do: get_env(:tenantex, Tenantex)[:schema_prefix] || "tenant_"
  
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

  def default_repo do
    get_appname()
    |> Application.get_env(:ecto_repos)
    |> List.first()    
  end

  def get_repo_adapter do
    get_appname()
    |> Application.get_env(get_repo())
    |> Keyword.fetch!(:adapter)
  end
end
