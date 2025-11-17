FROM apache/superset:latest

USER root

# Install system packages
RUN apt-get update && apt-get install -y \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv (required for uv pip)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Install drivers using uv pip
RUN uv pip install --no-cache-dir mysqlclient pymysql psycopg2

# Copy custom assets
COPY --chown=superset:superset loading.svg /app/superset-frontend/src/assets/images/loading.svg
COPY --chown=superset:superset superset_config.py /app/superset_config.py
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

USER superset

EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["/app/docker-entrypoint.sh"]
