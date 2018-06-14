FROM huggla/mariadb as mariadb
FROM huggla/alpine

USER root

COPY --from=mariadb /mariadb-apks /mariadb-apks
COPY ./start /start

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk \
 && rm -rf /mariadb-apks \
 && ln /usr/bin/mysqld /usr/local/bin/mysqld

ENV VAR_LINUX_USER="mysql" \
    VAR_CONFIG_DIR="/etc/mysql" \
    VAR_FINAL_COMMAND="MYSQL_HOME=\"\$VAR_CONFIG_DIR\" /usr/local/bin/mysqld" \
    VAR_param_datadir="'/mysqldata'"

USER starter
