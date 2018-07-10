FROM huggla/mariadb as mariadb
FROM huggla/alpine as tmp

USER root

COPY --from=mariadb /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-common-10.3.7-r0.apk
COPY --from=mariadb /mariadb-apks/mariadb-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk
COPY --from=mariadb /mariadb-apks/mariadb-client-10.3.7-r0.apk /mariadb-apks/mariadb-client-10.3.7-r0.apk
COPY ./start /rootfs/start
COPY ./initdb /rootfs/initdb 

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.7-r0.apk /mariadb-apks/mariadb-10.3.7-r0.apk /mariadb-apks/mariadb-client-10.3.7-r0.apk \
 && apk --no-cache add libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl \
 && tar -cpf /installed_files.tar $(apk manifest mariadb mariadb-common mariadb-client libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl | awk -F "  " '{print $2;}') \
 && tar -xpf /installed_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/usr/local/bin \
 && mv /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/mysqld mysqld

FROM huggla/alpine

USER root

COPY --from=tmp /rootfs /

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock"

USER starter
