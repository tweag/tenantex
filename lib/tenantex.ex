defmodule Tenantex do
  defmodule TenantMissingError do
    defexception message: "No tenant specified"
  end
  defdelegate drop_tenant(repo, tenant), to: Tenantex.Repo
  defdelegate new_tenant(repo, tenant), to: Tenantex.Repo

  def list_tenants, do: list_tenants(Application.get_env(:tenantex, Tenantex)[:tenants])
  defp list_tenants({module, func}), do: apply(module, func, [])
  defp list_tenants({module, func, args}), do: apply(module, func, args)
  defp list_tenants(tenants) when is_list(tenants), do: tenants
end
