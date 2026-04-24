# Task Tracker API

Rails 7 API-only app with GraphQL. The Vite client lives in [task-tracker-frontend](https://github.com/junko911/task-tracker-frontend).

**Live demo:** [https://task-tracker-web-eight.vercel.app](https://task-tracker-web-eight.vercel.app)

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

Source: [task-tracker-frontend](https://github.com/junko911/task-tracker-frontend)

Run the API on port **3001**, then in the frontend repo set either:

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
  signUp(email: "you@example.com", password: "secret123") {
    apiToken
    errors
    user { id email }
  }
}

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

## CI/CD

GitHub Actions runs on every push and pull request to `main`:

| Job | What it does |
|-----|-------------|
| **Test** | Runs the full test suite against Ruby 3.2 and 3.3 with a Postgres 16 service container |
| **Deploy** | Triggers a Render deploy hook — only runs on `main` push after tests pass |

### Required GitHub secrets

| Secret | Value |
|--------|-------|
| `RAILS_MASTER_KEY` | Contents of `config/master.key` |
| `RENDER_DEPLOY_HOOK_URL` | Render → your web service → **Settings** → Deploy Hook URL |

## Deployment (Render)

The app is deployed as a Docker-based Web Service on [Render](https://render.com).

### Required environment variables

| Variable | How to set it |
|---|---|
| `RAILS_ENV` | `production` |
| `DATABASE_URL` | Auto-injected by Render when you link a managed Postgres database |
| `SECRET_KEY_BASE` | Run `bundle exec rails secret` locally and paste the output |

The `entrypoint.sh` parses `DATABASE_URL` automatically, so no separate `DB_HOST` / `DB_PORT` variables are needed on Render.

### Build & start commands

Render uses the `Dockerfile` — no extra build/start commands required. The entrypoint handles `db:migrate` and seeding on every deploy.

## Task status values

| Value         | Meaning              |
|---------------|----------------------|
| `pending`     | Not yet started      |
| `in_progress` | In progress          |
| `completed`   | Done                 |
