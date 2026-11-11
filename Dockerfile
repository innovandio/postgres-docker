FROM debian:trixie-slim

ENV PG_VERSION=18
ENV DEBIAN_FRONTEND=noninteractive
ENV PGDATA=/var/lib/postgresql/data
ENV PATH="/usr/lib/postgresql/${PG_VERSION}/bin:$PATH"

# Fetched by BuildKit on the build host instead of curl inside the (possibly QEMU-emulated) build
ADD --chmod=644 https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc /usr/share/keyrings/postgresql.asc

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] \
      http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update && apt-get install -y --no-install-recommends \
      postgresql-${PG_VERSION} \
      postgresql-${PG_VERSION}-postgis-3 \
      postgresql-${PG_VERSION}-postgis-3-scripts \
      postgresql-${PG_VERSION}-pgvector \
      postgresql-${PG_VERSION}-partman \
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
CMD ["postgres", "-c", "listen_addresses=*"]
