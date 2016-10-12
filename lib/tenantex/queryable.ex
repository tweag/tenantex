defmodule Tenantex.Queryable do
  import Tenantex.Prefix
  alias Ecto.Changeset

  def set_tenant(%Changeset{} = changeset, tenant) do
    %{changeset | data: set_tenant(changeset.data, tenant)}
  end
  def set_tenant(%{__meta__: _} = model, tenant) do
    Ecto.put_meta(model,  prefix: schema_name(tenant))
  end
  def set_tenant(queryable, tenant) do
    queryable
    |> Ecto.Queryable.to_query
    |> Map.put(:prefix, schema_name(tenant))
  end
end
