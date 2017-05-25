defmodule Tenantex.Queryable do
  @moduledoc """
  WARNING: this module is deprecated. Add 'prefix' to your 'opts' from Ecto 2.1 on.
  """

  import Tenantex.Prefix
  alias Ecto.Changeset
  @msg "set_tenant is deprecated. Add 'prefix' to your 'opts' from Ecto 2.1 on."

  def set_tenant(%Changeset{} = changeset, tenant) do
    IO.warn(@msg, Macro.Env.stacktrace(__ENV__))
    %{changeset | data: set_tenant(changeset.data, tenant)}
  end

  def set_tenant(%{__meta__: _} = model, tenant) do
    IO.warn(@msg, Macro.Env.stacktrace(__ENV__))
    Ecto.put_meta(model,  prefix: schema_name(tenant))
  end

  def set_tenant(queryable, tenant) do
    IO.warn(@msg, Macro.Env.stacktrace(__ENV__))
    queryable
    |> Ecto.Queryable.to_query
    |> Map.put(:prefix, schema_name(tenant))
  end
end
