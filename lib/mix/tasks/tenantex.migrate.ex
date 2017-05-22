defmodule Mix.Tasks.Tenantex.Migrate do
  use Mix.Task
  import Mix.Tenantex
  @shortdoc "Migrates every tenant defined in your database"

  @moduledoc """
  Migrates all of the tenants

  Any arguments you specify will be passed along directly to Ecto's migrate command,
  so they're all fair game as well.  That said, prefix (--prefix) and repo (-r/--repo)
  will be overridden by what is in your config.

  ## Examples

      mix tenantex.migrate

  """

  def run(args, migrator \\ &Mix.Tasks.Tenantex.Migrate.migrate_with_prefix/2) do
    # Because migrations are loaded at run-time for each migration, warnings
    # about duplicate module definitions will happen for each tenant after the first
    # one. This silences that warning
    Code.compiler_options(ignore_module_conflict: true)

    Mix.Task.run "loadpaths", []
    Tenantex.list_tenants
    |> Enum.each(&migrator.(args, &1))
  end

  def migrate_with_prefix(args, prefix) do
    Mix.Tasks.Ecto.Migrate.run(args ++ ["--prefix", prefix], &ecto_migrator/4)
  end

  defp ecto_migrator(repo, _, direction, opts) do
    Ecto.Migrator.run(repo, tenant_migrations_path(repo), direction, opts)
  end
end
