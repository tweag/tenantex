defmodule Mix.Tasks.Tenantex.Rollback do
  use Mix.Task
  import Mix.Ecto
  import Mix.Tenantex
  @shortdoc "Rolls back every tenant"

  @moduledoc """
  Reverts applied migrations of all tenants

  Any arguments you specify will be passed along directly to Ecto's rollback command,
  so they're all fair game as well.  That said, prefix (--prefix) and repo (-r/--repo)
  will be overridden by what is in your config.

  ## Examples

      mix tenantex.rollback

  """

  def run(args, rollback \\ &__MODULE__.rollback_with_prefix/2) do
    # Because migrations are loaded at run-time for each migration, warnings
    # about duplicate module definitions will happen for each tenant after the first
    # one. This silences that warning

    Code.compiler_options(ignore_module_conflict: true)
    repo = Tenantex.get_repo()
    ensure_repo(repo, args)
    {:ok, pid, _apps} = ensure_started(repo, []) #TODO - Not respecting PoolSize
    sandbox? = repo.config[:pool] == Ecto.Adapters.SQL.Sandbox

    # If the pool is Ecto.Adapters.SQL.Sandbox,
    # let's make sure we get a connection outside of a sandbox.
    if sandbox? do
      Ecto.Adapters.SQL.Sandbox.checkin(repo)
      Ecto.Adapters.SQL.Sandbox.checkout(repo, sandbox: false)
    end

    tenants = Tenantex.list_tenants
    pid && repo.stop(pid)

    tenants
    |> Enum.each(&rollback.(args, &1))
  end

  def rollback_with_prefix(args, prefix) do
    Mix.Tasks.Ecto.Rollback.run(args ++ ["--prefix", prefix], &ecto_rollback/4)
  end

  defp ecto_rollback(repo, _, direction, opts) do
    Ecto.Migrator.run(repo, tenant_migrations_path(repo), direction, opts)
  end
end
