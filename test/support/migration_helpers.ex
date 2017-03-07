defmodule Support.MigrationHelpers do
  import ExUnit.Assertions
  alias Tenantex.Note
  alias Tenantex.TestTenantRepo

  def create_tenant_schema(tenant) do
    Tenantex.Repo.create_schema(TestTenantRepo, tenant)
  end

  def assert_notes_table_is_dropped(tenant) do
    assert_raise Postgrex.Error, fn ->
      find_tenant_notes(tenant)
    end
  end

  def find_tenant_notes(tenant) do
    TestTenantRepo.all(Note, prefix: tenant)
  end

  def create_and_migrate_tenant(tenant) do
    Tenantex.new_tenant(TestTenantRepo, tenant)
  end
end
