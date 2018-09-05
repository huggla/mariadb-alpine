FROM huggla/mariadb:10.3.9 as stage1
FROM huggla/alpine as stage2

ARG APKS="mariadb mariadb-client mariadb-server-utils"

COPY --from=stage1 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN find bin usr lib etc var home sbin root run srv -type d -print0 | sed -e 's|^|/rootfs/|' | xargs -0 mkdir -p \
 && cp -a /lib/apk/db /rootfs/lib/apk/ \
 && cp -a /etc/apk /rootfs/etc/ \
 && cd / \
 && cp -a /bin /sbin /rootfs/ \
 && cp -a /usr/bin /usr/sbin /rootfs/usr/ \
 && apk --no-cache --quiet info | xargs apk --quiet --no-cache --root /rootfs fix \
 && echo /mariadb-apks >> /etc/apk/repositories \
 && apk --no-cache --quiet --allow-untrusted --root /rootfs add $APKS \
 && rm /rootfs/usr/bin/sudo /rootfs/usr/bin/dash \
#mkdir -p /rootfs/lib/apk \
# && mv /lib/apk/db /rootfs/lib/apk/ \
# && ln -s /rootfs/lib/apk/db /lib/apk/ \
# && echo /mariadb-apks >> /etc/apk/repositories \
# && apk info > /pre_apks.list \
# && apk --no-cache --allow-untrusted add $APKS \
# && apk --no-cache add libgcc xz-libs libaio pcre libstdc++ libressl2.7-libcrypto libressl2.7-libssl ncurses-libs \
# && apk info > /post_apks.list \
# && apk manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{print $2}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
# && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
# && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/initdb \
 && mv /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
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

