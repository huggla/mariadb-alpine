ARG RUNDEPS="mariadb"
ARG MAKEDIRS="/initdb"
ARG REMOVEFILES="/etc/my.cnf.d/*"
ARG EXECUTABLES="/usr/bin/mysqld"

FROM huggla/busybox:20181017-edge as init
FROM huggla/build:20181017-edge as build
FROM huggla/base:20181017-edge as image

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock" \
    VAR_param_character_set_server="utf8" \
    VAR_param_collation_server="utf8_general_ci" \
    VAR_param_port=3306

ONBUILD USER root
