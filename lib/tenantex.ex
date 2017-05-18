defmodule Tenantex do
  defmodule TenantMissingError do
    defexception message: "No tenant specified"
  end
  defdelegate drop_tenant(repo, tenant), to: Tenantex.Repo
  defdelegate new_tenant(repo, tenant), to: Tenantex.Repo

  def list_tenants do
    Mix.Project.config()[:app]
      |> Application.get_env(:ecto_repos)
      |> List.first()
      |> Ecto.Adapters.SQL.query!("select schema_name from information_schema.schemata")
      |> Map.fetch!(:rows)
      |> Enum.filter_map(fn(schema) -> String.starts_with?(List.first(schema),Application.get_env(:tenantex, Tenantex)[:schema_prefix]) end, &(List.first(&1)) )
  end
  defp list_tenants({module, func}), do: apply(module, func, [])
  defp list_tenants({module, func, args}), do: apply(module, func, args)
  defp list_tenants(tenants) when is_list(tenants), do: tenants
end
