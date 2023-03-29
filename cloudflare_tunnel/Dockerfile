ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:stable
# hadolint ignore=DL3006
FROM $BUILD_FROM

# Set S6 verbosity level
ENV S6_VERBOSITY=1

# Setup base
ARG BUILD_ARCH=amd64

# Copy root filesystem
COPY rootfs /

# Run the script
RUN \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "aarch64" ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" = "armhf" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "armv7" ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" = "i386" ]]; then ARCH="386"; fi \
    && wget -O /usr/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARCH \
    && chmod +x /usr/bin/cloudflared

# Build arguments
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Wesley Menezes <https://github.com/w35l3y/>" \
    org.opencontainers.image.authors="Wesley Menezes <https://github.com/w35l3y/>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.url="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.vendor="Wesley Menezes <https://github.com/w35l3y/>" \
    org.opencontainers.image.version="${BUILD_VERSION}"