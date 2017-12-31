defmodule Mix.TenantexTest do
  use ExUnit.Case
  alias Tenantex.Test.TenantedRepo

  test ".tenant_migrations_path/1" do
    path = Mix.Tenantex.tenant_migrations_path(TenantedRepo)
    assert String.starts_with?(path, File.cwd!())
    assert String.ends_with?(path, "/priv/tenanted_repo/tenant_migrations")
  end
end
