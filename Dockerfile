FROM huggla/mariadb:10.3.9 as stage1
FROM huggla/alpine as stage2

COPY --from=stage1 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN apk info > /pre_apks.list \
 && apk --no-cache --allow-untrusted add /mariadb-apks/mariadb-common.apk /mariadb-apks/mariadb.apk /mariadb-apks/mariadb-client.apk /mariadb-apks/mariadb-server-utils.apk \
 && apk --no-cache add libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl ncurses-libs \
 && apk info > /post_apks.list \
 && apk manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{print $2}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/usr/local/bin /rootfs/initdb /rootfs/var/lib/mysql \
 && mv /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/ \
 && chmod ug=rwx,o= /rootfs/var/lib/mysql \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/mysqld mysqld

FROM huggla/alpine

COPY --from=stage2 /rootfs /

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock" \
    VAR_param_character_set_server="utf8" \
    VAR_param_collation_server="utf8_general_ci"

USER starter

ONBUILD USER root
