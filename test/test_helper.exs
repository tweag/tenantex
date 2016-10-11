defmodule Tenantex.TestPostgresRepo do
  use Ecto.Repo, otp_app: :tenantex, adapter: Ecto.Adapters.Postgres, pool: Ecto.Adapters.SQL.Sandbox
end

defmodule Tenantex.TestTenantRepo do
  use Tenantex, repo: Tenantex.TestPostgresRepo
end

Code.compiler_options(ignore_module_conflict: true)

Mix.Task.run "ecto.drop", ["quiet", "-r", "Tenantex.TestTenantRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "Tenantex.TestTenantRepo"]

Tenantex.TestTenantRepo.start_link
Ecto.TestRepo.start_link(url: "ecto://user:pass@local/hello")

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Tenantex.TestTenantRepo, :manual)
