ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:latest
FROM $BUILD_FROM

ARG BUILD_ARCH=amd64

COPY rootfs /

RUN \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "aarch64" ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" = "armhf" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "armv7" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "i386" ]]; then ARCH="386"; fi \
    && wget -O /usr/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARCH \
    && chmod +x /usr/bin/cloudflared
