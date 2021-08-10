ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
RUN \
 ARCH="${BUILD_ARCH}" \
 && if [[ "${BUILD_ARCH}" = "aarch64" ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" = "amd64" ]]; then ARCH="amd64"; fi \
    && if [[ "${BUILD_ARCH}" = "armhf" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "armv7" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "i386" ]]; then ARCH="386"; fi \

&& apk add --no-cache libc6-compat yq \

&& wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARCH && chmod +x /usr/local/bin/cloudflared

RUN cloudflared -v

COPY rootfs /