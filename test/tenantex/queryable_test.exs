defmodule Tenantex.QueryableTest do
  use ExUnit.Case
  alias Tenantex.Queryable

  @tenant_id 2

  test ".strip_prefix/1 removes the prefix from the schema" do
    assert Queryable.strip_prefix("tenant_#{@tenant_id}") == "#{@tenant_id}"
    assert Queryable.strip_prefix("tenant_somestring") == "somestring"
  end
end
