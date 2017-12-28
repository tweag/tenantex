Code.compiler_options(ignore_module_conflict: true)
Code.require_file "test/support/repos.ex"

Mix.Task.run "ecto.drop", ["quiet", "-r", "Tenantex.TestTenantRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "Tenantex.TestTenantRepo"]

Tenantex.TestTenantRepo.start_link
# Ecto.TestRepo.start_link(url: "ecto://user:pass@local/hello")

# ExUnit.configure(
#   exclude: :test, include: :focus
# )

ExUnit.start()

# Ecto.Adapters.SQL.Sandbox.mode(Tenantex.TestTenantRepo, :manual)
