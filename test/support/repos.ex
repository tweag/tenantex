defmodule Tenantex.TestPostgresRepo do
  use Ecto.Repo, otp_app: :tenantex, adapter: Ecto.Adapters.Postgres, pool: Ecto.Adapters.SQL.Sandbox
end

defmodule Tenantex.TestTenantRepo do
  use Tenantex.Repo, repo: Tenantex.TestPostgresRepo
end

defmodule Tenantex.Test.UntenantedRepo do
  use Tenantex.Repo, repo: Ecto.TestRepo, untenanted: [Tenantex.Note,Tenantex.Tag]
end

defmodule Tenantex.Test.TenantedRepo do
  use Tenantex.Repo, repo: Ecto.TestRepo
end
