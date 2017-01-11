defmodule Tenantex.Prefix do
  @prefix Application.get_env(:tenantex, Tenantex)[:schema_prefix] || "tenant_"
  def strip_prefix(table_prefix), do: String.replace_prefix(table_prefix, @prefix, "")

  def schema_name(tenant) when is_integer(tenant), do: @prefix <> Integer.to_string(tenant)
  def schema_name(tenant) when is_binary(tenant) do
    case String.starts_with?(tenant, @prefix) do
      true -> tenant
      false -> @prefix <> tenant
    end
  end
  def schema_name(nil), do: raise ArgumentError, "Tenant can not be nil"
end
