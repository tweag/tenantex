defmodule Mix.Tasks.Tenantex.MigrateTest do
  use ExUnit.Case
  alias Tenantex.TestTenantRepo
  alias Tenantex.Note
  import Support.MigrationHelpers
  import Tenantex.Queryable
  import Mix.Tasks.Tenantex.Migrate, only: [run: 1]

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestTenantRepo)
  end

  # Update with multiple tenants created
  # Verify the tables are there
  # Check the version migrated to.
  test "migrate up" do
    tenants = Tenantex.list_tenants
    Enum.each(tenants, fn(tenant) -> create_tenant_schema(tenant) end)

    responses = run([])

    assert Enum.count(responses) == Enum.count(tenants)
    Enum.each(responses, fn({status, _schema_name, versions}) ->
      assert status == :ok
      assert versions == [20160711125401]
    end)

    Enum.each(tenants, fn(tenant) ->
      num_notes = Note
      |> set_tenant(tenant)
      |> TestTenantRepo.all
      |> Enum.count
      assert num_notes == 0
    end)
  end
end
