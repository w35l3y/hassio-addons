ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
RUN \
    CVERSION="latest/download" \
#    CVERSION="download/2021.8.1" \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "aarch64" ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" = "amd64" ]]; then ARCH="amd64"; fi \
    && if [[ "${BUILD_ARCH}" = "armhf" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "armv7" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "i386" ]]; then ARCH="386"; fi \
    && apk add --no-cache libc6-compat yq \
    && echo "Version: $CVERSION / Architeture: $ARCH" \
    && wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/$CVERSION/cloudflared-linux-$ARCH && chmod +x /usr/local/bin/cloudflared

COPY rootfs /

RUN cloudflared -v

