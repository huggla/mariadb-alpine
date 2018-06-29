FROM huggla/mariadb as mariadb
FROM huggla/alpine:20180628-edge as tmp

USER root

COPY --from=mariadb /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-common-10.3.7-r0.apk
COPY --from=mariadb /mariadb-apks/mariadb-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk \
 && tar -zcpf /mariadb.tar.gz $(apk manifest mariadb mariadb-common | awk -F "  " '{print $2;}') \
 && mkdir -p /tmp/root /
 && tar -zxpf /mariadb.tar.gz -C /tmp/root/

FROM huggla/alpine:20180628-edge

USER root

COPY --from=tmp /tmp/root /
COPY ./start /start
COPY ./initdb /initdb 

RUN apk --no-cache add libressl2.7-libcrypto libressl2.7-libssl \
 && tar -zxpf /mariadb.tar.gz -C / \
 && ln /usr/bin/mysqld /usr/local/bin/mysqld

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata"

USER starter
