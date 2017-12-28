defmodule Mix.Tenantex do
  @doc """
  Gets the migrations path from a repository.
  """
  @spec tenant_migrations_path(Ecto.Repo.t) :: String.t
  def tenant_migrations_path(repo) do
    repo_priv = repo.config()[:priv] || "priv/#{repo |> Module.split |> List.last |> Macro.underscore}"
    repo_priv_fullpath = Application.app_dir(Keyword.fetch!(repo.config(), :otp_app), repo_priv)
    Path.join(repo_priv_fullpath, "tenant_migrations")
  end
end
