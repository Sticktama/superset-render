#!/bin/bash
set -e

# Run DB migrations
superset db upgrade

# Create admin if not exists
superset fab create-admin \
  --username "${SUPERSET_ADMIN_USERNAME}" \
  --firstname "${SUPERSET_ADMIN_FIRSTNAME}" \
  --lastname "${SUPERSET_ADMIN_LASTNAME}" \
  --email "${SUPERSET_ADMIN_EMAIL}" \
  --password "${SUPERSET_ADMIN_PASSWORD}" || true

# Initialize Superset
superset init

# Start the web server (main PID)
exec superset run -h 0.0.0.0 -p 8088
