#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for the database to be ready
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME"; do
  echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
  sleep 2
done

echo "PostgreSQL is ready"

# Create the database if it doesn't exist, then migrate
bundle exec rails db:create db:migrate

# Seed only if the database is empty
bundle exec rails runner "Task.count == 0 && Rails.application.load_seed" 2>/dev/null || true

exec "$@"
