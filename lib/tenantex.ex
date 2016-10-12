defmodule Tenantex do
  defmodule TenantMissingError do
    defexception message: "No tenant specified"
  end
  defdelegate drop_tenant(repo, tenant), to: Tenantex.Repo
  defdelegate migrate_tenant(repo, tenant, direction \\ :up, opts \\ []), to: Tenantex.Migrator
  defdelegate new_tenant(repo, tenant), to: Tenantex.Repo
end
