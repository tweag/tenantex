defmodule Tenantex.Queryable do
  alias Ecto.Changeset
  @prefix Application.get_env(:tenantex, :schema_prefix) || "tenant_"

  def set_tenant(%Changeset{} = changeset, tenant) do
    %{changeset | data: set_tenant(changeset.data, tenant)}
  end
  def set_tenant(%{__meta__: _} = model, tenant) do
    Ecto.put_meta(model,  prefix: _build_prefix(tenant))
  end
  def set_tenant(queryable, tenant) do
    queryable
    |> Ecto.Queryable.to_query
    |> Map.put(:prefix, _build_prefix(tenant))
  end

  def strip_prefix(table_prefix), do: String.replace_prefix(table_prefix, @prefix, "")

  def _build_prefix(tenant) when is_integer(tenant), do: @prefix <> Integer.to_string(tenant)
  def _build_prefix(tenant) when is_binary(tenant), do: @prefix <> tenant
  def _build_prefix(tenant) do
    cond do
      is_binary(tenant.id) -> @prefix <> tenant.id
      is_integer(tenant.id) -> @prefix <> Integer.to_string(tenant.id)
    end
  end

end
