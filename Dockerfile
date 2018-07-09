FROM huggla/mariadb as mariadb
FROM huggla/alpine:20180628-edge as tmp

USER root

COPY --from=mariadb /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-common-10.3.7-r0.apk
COPY --from=mariadb /mariadb-apks/mariadb-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk
COPY ./start /tmp/root/start
COPY ./initdb /tmp/root/initdb 

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk \
 && apk --no-cache add libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl \
 && tar -cpf /installed_files.tar $(apk manifest mariadb mariadb-common libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl | awk -F "  " '{print $2;}') \
 && tar -xpf /installed_files.tar -C /tmp/root/ \
 && mkdir -p /tmp/root/usr/local/bin \
 && mv /tmp/root/usr/bin/mysqld /tmp/root/usr/local/bin/mysqld \
 && cd /tmp/root/usr/bin \
 && ln -s ../local/bin/mysqld mysqld

FROM huggla/alpine:20180628-edge

USER root

COPY --from=tmp /tmp/root /

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock"

USER starter
