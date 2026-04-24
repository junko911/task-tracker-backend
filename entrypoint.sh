#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set. Check environment variables on Render."
  exit 1
fi

# Wait for the database to be ready using the full URL
# The -d flag tells pg_isready to use the connection string directly
WAIT_LIMIT=30
WAIT_COUNT=0

echo "Checking database connection..."
until pg_isready -d "$DATABASE_URL"; do
  WAIT_COUNT=$((WAIT_COUNT + 1))
  if [ "$WAIT_COUNT" -ge "$WAIT_LIMIT" ]; then
    echo "ERROR: Database did not become ready in time. Verify your DATABASE_URL on Render."
    exit 1
  fi
  echo "Waiting for PostgreSQL... ($WAIT_COUNT/$WAIT_LIMIT)"
  sleep 2
done

echo "PostgreSQL is ready!"

# Run migrations
bundle exec rails db:prepare

# Optional: Seed demo data if needed
bundle exec rails runner "User.find_by(email: 'demo@example.com').nil? && Rails.application.load_seed" 2>/dev/null || true

exec "$@"
