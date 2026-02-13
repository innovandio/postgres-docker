FROM debian:trixie-slim

ENV PG_VERSION=18
ENV DEBIAN_FRONTEND=noninteractive
ENV PGDATA=/var/lib/postgresql/data
ENV PATH="/usr/lib/postgresql/${PG_VERSION}/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates gnupg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] \
      http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update && apt-get install -y --no-install-recommends \
      postgresql-${PG_VERSION} \
      postgresql-${PG_VERSION}-postgis-3 \
      postgresql-${PG_VERSION}-postgis-3-scripts \
      postgresql-${PG_VERSION}-pgvector \
      gosu \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$PGDATA" /var/run/postgresql /docker-entrypoint-initdb.d \
    && chown -R postgres:postgres "$PGDATA" /var/run/postgresql /docker-entrypoint-initdb.d

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

STOPSIGNAL SIGINT
VOLUME /var/lib/postgresql/data
EXPOSE 5432

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
