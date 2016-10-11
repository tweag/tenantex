defmodule Tenantex.TenantexTest do
  use ExUnit.Case

  # alias Tenantex.Note
  # alias Tenantex.TestPostgresRepo
  # import Tenantex.RepoAdditions

  @tenant_id 2

  test ".extract_tenant/1 removes the prefix from the schema" do
    assert Tenantex.PrefixBuilder.extract_tenant("tenant_#{@tenant_id}") == "#{@tenant_id}"
    assert Tenantex.PrefixBuilder.extract_tenant("tenant_somestring") == "somestring"
  end
end
