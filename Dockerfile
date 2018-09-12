FROM huggla/mariadb:10.3.9 as stage1
FROM huggla/alpine:20180907-edge as stage2
FROM huggla/alpine-official:20180907-edge as stage3

ARG APKS="mariadb libressl2.7-libcrypto libressl2.7-libssl libstdc++"

COPY --from=stage1 /mariadb-apks /mariadb-apks
COPY --from=stage2 / /rootfs
COPY ./rootfs /rootfs 

RUN echo /mariadb-apks >> /etc/apk/repositories \
 && apk --no-cache --quiet info > /pre_apks.list \
 && sed -i '/libressl2.7-libcrypto/d' /pre_apks.list \
 && sed -i '/libressl2.7-libssl/d' /pre_apks.list \
 && apk --no-cache --allow-untrusted add $APKS \
 && apk --no-cache --quiet info > /post_apks.list \
 && apk --no-cache --quiet manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{s=""; for (i=2; i < NF; i++) s = s $i "+"; print s $NF}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/initdb \
 && mv /rootfs/usr/bin/mysqld /rootfs/usr/local/bin/mysqld \
 && mv /rootfs/etc/my.cnf /rootfs/etc/my.cnf.off \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/mysqld mysqld

FROM huggla/alpine:20180907-edge

COPY --from=stage3 /rootfs /

ENV VAR_LINUX_USER="mysql" \
    VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig" \
    VAR_param_datadir="/mariadbdata" \
    VAR_param_socket="/run/mysqld/mysqld.sock" \
    VAR_param_character_set_server="utf8" \
    VAR_param_collation_server="utf8_general_ci"

USER starter

ONBUILD USER root
