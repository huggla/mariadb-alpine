FROM huggla/mariadb as mariadb
FROM huggla/alpine

USER root

COPY --from=mariadb /mariadb-apks /mariadb-apks
COPY ./start /start

RUN cd /mariadb-apks \
 && apk update \
 && apk --allow-untrusted add ./*.apk
 && rm -rf /mariadb-apks \
 && ln /usr/bin/mysqld /usr/local/bin/mysqld

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata"

USER starter
