FROM huggla/mariadb as mariadb
FROM huggla/alpine

USER root

COPY --from=mariadb /mariadb-apks /mariadb-apks
COPY ./start /start



ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata"

USER starter
