defmodule Tenantex.Prefix do
  @prefix Application.get_env(:tenantex, :schema_prefix) || "tenant_"
  def strip_prefix(table_prefix), do: String.replace_prefix(table_prefix, @prefix, "")

  def schema_name(tenant) when is_integer(tenant), do: @prefix <> Integer.to_string(tenant)
  def schema_name(tenant) when is_binary(tenant), do: @prefix <> tenant
  def schema_name(nil), do: raise ArgumentError, "Tenant can not be nil"
end
