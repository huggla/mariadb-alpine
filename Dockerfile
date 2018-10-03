ARG ADDREPOS="/tmp/mariadb-apks"
ARG RUNDEPS="libressl2.7-libssl"
ARG RUNDEPS_UNTRUSTED="mariadb"
ARG MAKEDIRS="/initdb"
ARG REMOVEFILES="/etc/my.cnf.d/*"
ARG EXECUTABLES="/usr/bin/mysqld"

FROM huggla/mariadb:10.3.9 as mariadb
FROM huggla/busybox:20180921-edge as init

COPY --from=mariadb /mariadb-apks /tmp/mariadb-apks

FROM huggla/build as build

FROM huggla/base as image

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock" \
    VAR_param_character_set_server="utf8" \
    VAR_param_collation_server="utf8_general_ci" \
    VAR_param_port=3306

ONBUILD USER root
