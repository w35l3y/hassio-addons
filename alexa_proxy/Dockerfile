ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

COPY rootfs /

RUN apk add --no-cache --update nodejs npm && npm install
