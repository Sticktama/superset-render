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

RUN /app/docker/apt-install.sh \
    git \
    pkg-config \
    default-libmysqlclient-dev


# Copy custom loading indicator and config
COPY --chown=superset:superset loading.svg /app/superset-frontend/src/assets/images/loading.svg
COPY --chown=superset:superset superset_config.py /app/superset_config.py

# Copy entrypoint and make it executable as root
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh


# Switch to superset user
USER superset
EXPOSE 8088

CMD ["/app/docker-entrypoint.sh"]
