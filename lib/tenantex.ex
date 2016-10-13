defmodule Tenantex do
  defmodule TenantMissingError do
    defexception message: "No tenant specified"
  end
  defdelegate drop_tenant(repo, tenant), to: Tenantex.Repo
  defdelegate migrate_tenant(repo, tenant, direction \\ :up, opts \\ []), to: Tenantex.Migrator
  defdelegate new_tenant(repo, tenant), to: Tenantex.Repo

  def load_tenants, do: load_tenants(Application.get_env :tenantex, :load_tenants)
  defp load_tenants({module, func}), do: apply(module, func, [])
  defp load_tenants({module, func, args}), do: apply(module, func, args)
  defp load_tenants(tenants) when is_list(tenants), do: tenants
end
