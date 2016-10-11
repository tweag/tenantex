[![CircleCI](https://circleci.com/gh/jeffdeville/tenantex/tree/master.svg?style=shield)](https://circleci.com/gh/jeffdeville/tenantex/tree/master)

# Tenantex

Tenantex is a fork of https://github.com/Dania02525/apartmentex
There was some fantastic work done there, but I wanted to take a slightly different approach.

Easy SaaS for Phoenix/Ecto.

In this branch, the following versions are supported:
* Ecto 2.0.x
* Postgrex 0.11.0

### Features
* Tenant-qualified queries targeting postgres schemas or MySql databases
* Automatic migrations for tenant tables to schema for Postgres or
database for MySQL

### Setup

- Add this to your mix.exs deps:
```elixir
{:tenantex, "~> 0.1.0"}
```
- Run mix deps.get && mix deps.compile

- You can also configure your tenant schema prefix, adding this to your application configs:
```elixir
config :tenantex, schema_prefix: "prefix_" # the default prefix is "tenant_"
```

### Use

Generate a migration file that will be run against each tenant:

```
mix tenantex.gen.migration CreateUsers
```

By default, the migration will be generated to the
"priv/YOUR_REPO/tenant_migrations" directory of the current application but it
can be configured to be any subdirectory of `priv` by specifying the `:priv` key
under the repository configuration.

You can now add a new tenant and automatically create a new schema for Postgres
users or a new database for MySQL users, and run the migrations in
priv/YOUR_REPO/tenant_migrations for that schema or database.

Table references and indexes in a migration will be applied to the same tenant
prefix as the table within tenant_migrations.

```elixir
Tenantex.new_tenant(Repo, tenant)
```

When you need to update a tenant's schema based on new migrations, you can run:

```elixir
# Runs all migrations necessary for the tenant, based on that tenant's
`schema_migrations` table
# Returns a tuple that is either:
# {:ok, prefix_of_tenant, versions_migrated}
# {:error, prefix_of_tenant, db_error_message}

{status, prefix, versions_or_error} = Tenantex.migrate_tenant(Repo, tenant)
```

If there is a problem with a migration, you can roll it back by passing in the
version (as an integer). This will revert every migration back until the version
specified (including that version):

```elixir
# Returns a tuple that is either:
# {:ok, prefix_of_tenant, versions_rolled_back}
# {:error, prefix_of_tenant, db_error_message}

{status, prefix, versions_or_error} = Tenantex.migrate_tenant(Repo, tenant, :down, to: 20160711125401)
```

When deleting a tenant, you can also automatically drop their associated schema or database (for MySQL).

```elixir
Tenantex.drop_tenant(Repo, tenant)
```


### To Do

- mix task to migrate or rollback all tenant schemas/databases
