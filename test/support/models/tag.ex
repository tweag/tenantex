defmodule Tenantex.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    belongs_to :note, Tenantex.Note
  end

  def changeset(model, params \\ :empty) do
    model |> cast(params, ~w(name))
  end
end
