# Task Tracker API

Rails 7 API-only app with GraphQL. The Vite client lives in `frontend/` next to this folder.

## Stack

| Layer     | Technology          |
|-----------|---------------------|
| Runtime   | Ruby 3.2.2+ (see `Gemfile`) |
| Framework | Rails 7.1 (API)     |
| API       | GraphQL (graphql)   |
| Database  | PostgreSQL 16     |

## Quick start (Docker)

```bash
docker compose up --build
```

GraphQL: [http://localhost:3001/graphql](http://localhost:3001/graphql)

## Local development (without Docker)

```bash
bundle install
rails db:create db:migrate db:seed
rails server -p 3001
```

Ensure PostgreSQL is running. Defaults in [`config/database.yml`](config/database.yml) use `DB_USERNAME` / `DB_PASSWORD` (default `postgres` / `postgres`, same as Docker). On **macOS Homebrew** Postgres you often have no `postgres` role — use your login user, for example:

```bash
export DB_USERNAME="$(whoami)"
export DB_PASSWORD=""
rails db:create db:migrate db:seed
rails server -p 3001
```

## Tests

```bash
bin/rails db:test:prepare
bin/rails test
```

Run one file: `bin/rails test test/integration/graphql_authentication_test.rb`

**Docker** (no local Postgres role tuning):

```bash
docker compose up -d db
docker compose run --rm --entrypoint "" api sh -c "bundle install && RAILS_ENV=test bin/rails db:test:prepare test"
```

`--entrypoint ""` skips the API container entrypoint so `bundle install` can refresh gems against the mounted `Gemfile.lock` before tests.

## Frontend

Run the API on port **3001**. In `frontend/` set either:

- `VITE_GRAPHQL_URL=http://localhost:3001/graphql`, or
- `VITE_GRAPHQL_URL=/graphql` and `API_PROXY_TARGET=http://127.0.0.1:3001` if you proxy through Vite.

CORS is wide open in dev (`origins '*'`). Lock that down in `config/application.rb` before production.

## GraphQL

Send queries and mutations as `POST /graphql` (JSON body: `query`, `variables`, `operationName`).

### Authentication

Task queries and task mutations require header:

`Authorization: Bearer <api_token>`

Get a token with `signUp` or `signIn` (no auth header needed). After `db:seed`, demo user is `demo@example.com` / `password12`; seed output prints that user’s `api_token`.

```graphql
mutation {
  signIn(email: "demo@example.com", password: "password12") {
    apiToken
    errors
    user { id email }
  }
}
```

### Queries

Send authenticated queries with the `Authorization` header set to `Bearer <api_token>`.

```graphql
query {
  tasks(status: pending) {
    id title description status createdAt updatedAt
  }
}

query {
  task(id: "1") {
    id title description status
  }
}
```

### Mutations

`createTask`, `updateTask`, and `deleteTask` require the same `Authorization` header.

```graphql
mutation {
  createTask(title: "My task", description: "Details", status: pending) {
    task { id title status }
    errors
  }
}

mutation {
  updateTask(id: "1", status: completed) {
    task { id title status }
    errors
  }
}

mutation {
  deleteTask(id: "1") {
    success errors
  }
}
```

## Task status values

| Value         | Meaning              |
|---------------|----------------------|
| `pending`     | Not yet started      |
| `in_progress` | In progress          |
| `completed`   | Done                 |
