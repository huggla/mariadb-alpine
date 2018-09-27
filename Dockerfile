FROM huggla/mariadb:10.3.9 as stage2
FROM huggla/alpine-slim:20180927-edge as stage1

ARG APKS="mariadb libressl2.7-libssl"

COPY --from=stage2 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN echo /mariadb-apks >> /etc/apk/repositories \
 && mkdir -p /rootfs/etc \
 && cp -a /lib /rootfs/ \
 && cp -a /etc/apk /rootfs/etc/ \
 && apk --no-cache --allow-untrusted --root /rootfs add $APKS \
# && apk --no-cache --quiet info > /apks.list \
# && apk --no-cache --quiet manifest $(cat /apks.list) | awk -F "  " '{print $2;}' > /apks_files.list \
# && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
# && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/initdb /rootfs/usr/local/bin \
 && rm -rf /rootfs/etc/my.cnf.d/* /mariadb-apks \
 && cp -a /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
 && cd /rootfs/usr/bin \
 && ln -fs ../local/bin/mysqld mysqld

FROM huggla/base:20180927-edge

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock" \
    VAR_param_character_set_server="utf8" \
    VAR_param_collation_server="utf8_general_ci" \
    VAR_param_port=3306

ONBUILD USER root
