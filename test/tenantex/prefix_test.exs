defmodule Tenantex.PrefixTest do
  use ExUnit.Case
  import Tenantex.Prefix

  @tenant_id 2

  test ".strip_prefix/1 removes the prefix from the schema" do
    assert strip_prefix("tenant_#{@tenant_id}") == "#{@tenant_id}"
    assert strip_prefix("tenant_somestring") == "somestring"
  end

  describe "schema_name" do
    test "schema_name\1 when is_integer prefixes the integer with the prefix value" do
      assert schema_name(1) == "tenant_1"
    end

    test "schema_name\1 when prefix is omitted" do
      assert schema_name("test") == "tenant_test"
    end

    test "schema_name\1 when prefix is included" do
      assert schema_name("tenant_test") == "tenant_test"
    end
  end
end
