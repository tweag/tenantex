use Mix.Config

config :tenantex, Tenantex.TestPostgresRepo,
  hostname: "localhost",
  database: "tenantex_test",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

config :tenantex, Ecto.TestRepo,
  url: "ecto://user:pass@local/hello"

config :tenantex,
  ecto_repos: [Tenantex.TestTenantRepo]

config :tenantex, Tenantex,
  tenants: ["test1", "test2"],
  schema_prefix: "tenant_"

config :logger, level: :warn
