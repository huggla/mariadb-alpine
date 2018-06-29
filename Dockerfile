FROM huggla/mariadb as mariadb
FROM huggla/alpine:20180628-edge as tmp

USER root

COPY --from=mariadb /mariadb-apks /mariadb-apks

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk \
 && tar -zcpf /mariadb.tar.gz $(apk manifest mariadb mariadb-common | awk -F "  " '{print $2;}')

FROM huggla/alpine:20180628-edge

USER root

COPY --from=tmp /mariadb.tar.gz /mariadb.tar.gz
COPY ./start /start
COPY ./bin /usr/local/bin

RUN apk --no-cache add libressl2.7-libcrypto libressl2.7-libssl \
 && ln /usr/bin/mysqldump /usr/local/bin/mysqldump

ENV VAR_LINUX_USER="mysql" \
    VAR_PORT="3306"

USER starter


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
