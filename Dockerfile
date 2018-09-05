FROM huggla/mariadb:10.3.9 as stage1
FROM huggla/alpine as stage2

ARG APKS="mariadb mariadb-client mariadb-server-utils"

COPY --from=stage1 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN find bin usr lib etc var home sbin root run srv -type d -print0 | sed -e 's|^|/rootfs/|' | xargs -0 mkdir -p \
 && cp -a /lib/apk/db /rootfs/lib/apk/ \
 && cp -a /etc/apk /rootfs/etc/ \
 && cp -a /bin /sbin /rootfs/ \
 && cp -a /usr/bin /usr/sbin /rootfs/usr/ \
 && apk --no-cache --quiet info | xargs apk --quiet --no-cache --root /rootfs fix \
 && echo /mariadb-apks >> /etc/apk/repositories \
 && apk --no-cache --quiet --allow-untrusted --root /rootfs add $APKS \
 && rm /rootfs/usr/bin/sudo /rootfs/usr/bin/dash \
 && mkdir -p /rootfs/initdb \
 && mv /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
 && mv /rootfs/etc/my.cnf /rootfs/etc/my.cnf.off \
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

