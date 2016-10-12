defmodule Tenantex.MigratorTest do
  use ExUnit.Case

  import Support.MigrationHelpers
  alias Tenantex.TestTenantRepo

  @migration_version 20160711125401
  @wrong_migration_version 20160711125402
  @repo TestTenantRepo
  @tenant 2

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(@repo)
  end

  test ".migrate_tenant/4 migrates the tenant forward by default" do
    create_tenant_schema @tenant

    {status, prefix, versions} = Tenantex.migrate_tenant(@repo, @tenant)

    assert status == :ok
    assert prefix == "tenant_#{@tenant}"
    assert versions == [@migration_version]

  end

  test ".migrate_tenant/4 returns an error tuple when it fails" do
    create_and_migrate_tenant @tenant

    force_migration_failure fn(expected_postgres_error) ->
      {status, prefix, error_message} = Tenantex.migrate_tenant(@repo, @tenant)

      assert status == :error
      assert prefix == "tenant_#{@tenant}"
      assert error_message == expected_postgres_error
    end
  end

  test ".migrate_tenant/4 can rollback and return metadata" do
    create_and_migrate_tenant @tenant

    # assert_drops_notes_table(@tenant) fn ->
      {status, prefix, versions} =
        Tenantex.migrate_tenant(@repo, @tenant, :down, to: @migration_version)

      assert status == :ok
      assert prefix == "tenant_#{@tenant}"
      assert versions == [@migration_version]
    # end
  end

  test ".migrate_tenant/4 returns a tuple when it fails to rollback" do
    create_and_migrate_tenant @tenant

    force_rollback_failure fn(expected_postgres_error) ->
      {status, prefix, error_message} =
        Tenantex.migrate_tenant(@repo, @tenant, :down, to: @migration_version)

      assert status == :error
      assert prefix == "tenant_#{@tenant}"
      assert error_message == expected_postgres_error
    end
  end

  defp force_migration_failure(migration_function) do
    sql = """
    DELETE FROM "tenant_#{@tenant}"."schema_migrations"
    """

    @repo |> Ecto.Adapters.SQL.query(sql, [])

    migration_function.("ERROR (duplicate_table): relation \"notes\" already exists")
  end

  defp force_rollback_failure(rollback_function) do
    sql = """
    DROP TABLE "tenant_#{@tenant}"."notes";
    """

    @repo |> Ecto.Adapters.SQL.query(sql, [])

    rollback_function.("ERROR (undefined_table): table \"notes\" does not exist")
  end
end
