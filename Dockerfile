FROM huggla/mariadb:10.3.9 as stage1
FROM huggla/alpine-slim:20180907-edge as stage2

ARG APKS="mariadb libressl2.7-libcrypto libressl2.7-libssl libressl2.7-libtls libstdc++"

COPY --from=stage1 /mariadb-apks /mariadb-apks
COPY ./rootfs /rootfs 

RUN echo /mariadb-apks >> /etc/apk/repositories \
 && apk --no-cache --allow-untrusted add $APKS \
 && apk --no-cache --quiet info > /apks.list
