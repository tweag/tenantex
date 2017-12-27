defmodule Mix.Tenantex do
  import Mix.Ecto, only: [source_repo_priv: 1]

  @doc """
  Gets the migrations path from a repository.
  """
  @spec tenant_migrations_path(Ecto.Repo.t) :: String.t
  def tenant_migrations_path(repo) do
    Path.join(source_repo_priv(repo), "tenant_migrations")
  end
end
