defmodule Mix.Tasks.Tenantex.MigrateTest do
  use ExUnit.Case
  import Mix.Tasks.Tenantex.Migrate, only: [run: 2]

  test "runs migration for each tenant, with the correct prefix" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Tenantex.TestTenantRepo)
    expected_args = ["-r", "Tenantex.TestTenantRepo"]
    run(expected_args, fn(args, prefix) ->
      assert prefix in ~w(tenant_test1 tenant_test2)
      assert args == expected_args
    end)
  end
end
