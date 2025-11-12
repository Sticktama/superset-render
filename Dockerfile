FROM apache/superset:latest

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq-dev \
        build-essential && \
    pip install psycopg2-binary && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER superset
EXPOSE 8088

# Optional: create a script for initialization
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

CMD ["/app/docker-entrypoint.sh"]
