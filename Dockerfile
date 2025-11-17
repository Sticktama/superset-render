FROM apache/superset:master

# Install PostgreSQL client libraries
USER root

USER root
RUN apt-get update && apt-get install -y \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

    
RUN uv pip install --no-cache-dir mysqlclient pymysql psycopg2

# Copy custom loading indicator and config
COPY --chown=superset:superset loading.svg /app/superset-frontend/src/assets/images/loading.svg
COPY --chown=superset:superset superset_config.py /app/superset_config.py

# Copy entrypoint and make it executable as root
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh


# Switch to superset user
USER superset
EXPOSE 8088

HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["/app/docker-entrypoint.sh"]
