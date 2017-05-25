defmodule Tenantex.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :body, :string
    has_many :tags, Tenantex.Tag
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(body))
  end
end
