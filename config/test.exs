use Mix.Config

config :tenantex, Tenantex.TestPostgresRepo,
  hostname: "localhost",
  database: "tenantex_test",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

config :tenantex, Ecto.TestRepo,
  url: "ecto://user:pass@local/hello"

config :tenantex, repo: Tenantex.TestTenantRepo, list_tenants: ["test1", "test2"]


config :logger, level: :warn
