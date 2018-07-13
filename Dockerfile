FROM huggla/mariadb:10.3.8 as stage1
FROM huggla/alpine:20180713-edge as stage2

USER root

COPY --from=stage1 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common-10.3.8-r0.apk /mariadb-apks/mariadb-10.3.8-r0.apk \
 && apk --no-cache add libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl \
 && tar -cvp -f /installed_files.tar $(apk manifest mariadb mariadb-common libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl | awk -F "  " '{print $2;}') \
 && tar -xvp -f /installed_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/usr/local/bin \
 && mv /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/mysqld mysqld

FROM huggla/alpine:20180713-edge

COPY --from=stage2 /rootfs /

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock"
