FROM alpine:3.22

RUN apk add --no-cache \
      postgresql18 \
      postgresql18-contrib \
      postgresql18-jit \
      postgis \
      pgvector \
      su-exec \
      bash \
      tzdata \
    && mkdir -p /var/lib/postgresql/data /var/run/postgresql /docker-entrypoint-initdb.d \
    && chown -R postgres:postgres /var/lib/postgresql /var/run/postgresql /docker-entrypoint-initdb.d

ENV LANG=en_US.utf8
ENV PG_MAJOR=18
ENV PGDATA=/var/lib/postgresql/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

STOPSIGNAL SIGINT

USER postgres

VOLUME /var/lib/postgresql/data
EXPOSE 5432

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
