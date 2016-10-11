use Mix.Config

config :tenantex, Tenantex.TestPostgresRepo,
  hostname: "localhost",
  database: "tenantex_test",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

config :tenantex, Ecto.TestRepo,
  url: "ecto://user:pass@local/hello"


config :logger, level: :warn
