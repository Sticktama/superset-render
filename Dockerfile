# Dockerfile

FROM apache/superset:latest

# Install PostgreSQL client libraries and build tools for psycopg2
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq-dev \
        build-essential && \
    pip install psycopg2-binary && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Restore default user
USER superset

# Expose port for Render
EXPOSE 8088

# Initialize and run Superset
CMD /bin/bash -c "\
  superset db upgrade && \
  superset fab create-admin \
    --username ${SUPERSET_ADMIN_USERNAME} \
    --firstname ${SUPERSET_ADMIN_FIRSTNAME} \
    --lastname ${SUPERSET_ADMIN_LASTNAME} \
    --email ${SUPERSET_ADMIN_EMAIL} \
    --password ${SUPERSET_ADMIN_PASSWORD} && \
  superset init && \
  superset run -h 0.0.0.0 -p 8088"

