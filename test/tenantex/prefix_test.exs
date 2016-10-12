defmodule Tenantex.PrefixTest do
  use ExUnit.Case
  alias Tenantex.Prefix

  @tenant_id 2

  test ".strip_prefix/1 removes the prefix from the schema" do
    assert Prefix.strip_prefix("tenant_#{@tenant_id}") == "#{@tenant_id}"
    assert Prefix.strip_prefix("tenant_somestring") == "somestring"
  end
end
