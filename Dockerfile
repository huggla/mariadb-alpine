FROM huggla/mariadb:10.3.9 as mariadb
FROM huggla/busybox as init

COPY --from=mariadb /mariadb-apks /mariadb-apks

ARG ADDREPOS="/mariadb-apks"
ARG RUNDEPS="libressl2.7-libssl"
ARG RUNDEPS_UNTRUSTED="mariadb"

COPY --from=stage2 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN echo /mariadb-apks >> /etc/apk/repositories \
 && apk --no-cache --allow-untrusted --root /rootfs add $APKS \
 && mkdir -p /rootfs/initdb \
 && rm -rf /rootfs/etc/my.cnf.d/* /mariadb-apks \
 && cp -a /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
 && cd /rootfs/usr/bin \
 && ln -fs ../local/bin/mysqld mysqld

FROM huggla/base

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock" \
    VAR_param_character_set_server="utf8" \
    VAR_param_collation_server="utf8_general_ci" \
    VAR_param_port=3306

ONBUILD USER root
