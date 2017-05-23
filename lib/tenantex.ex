defmodule Tenantex do
  defmodule TenantMissingError do
    defexception message: "No tenant specified"
  end
  defdelegate drop_tenant(tenant), to: Tenantex.Repo
  defdelegate new_tenant(tenant), to: Tenantex.Repo
  defdelegate list_tenants(), to: Tenantex.Repo
  defdelegate get_repo(), to: Tenantex.Repo
end
