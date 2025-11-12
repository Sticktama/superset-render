FROM apache/superset:latest

# Install PostgreSQL client libraries
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq-dev \
        build-essential && \
    pip install psycopg2-binary && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint and make it executable as root
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Switch to superset user
USER superset
EXPOSE 8088

CMD ["/app/docker-entrypoint.sh"]
