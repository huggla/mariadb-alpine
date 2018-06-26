FROM huggla/mariadb as mariadb
FROM huggla/alpine:20180614-edge

USER root

COPY --from=mariadb /mariadb-apks /mariadb-apks
COPY ./start /start

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk \
 && rm -rf /mariadb-apks \
 && ln /usr/bin/mysqld /usr/local/bin/mysqld

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata"

USER starter
