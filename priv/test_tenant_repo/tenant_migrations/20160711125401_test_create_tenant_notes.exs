defmodule Tenantex.TestTenantRepo.Migrations.CreateTenantUser do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :body, :string
    end

    create table(:tags) do
      add :name, :string
      add :note_id, references(:notes)
    end
  end
end
