ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_CHROMIUM_REVISION=902218

COPY rootfs /

ARG BUILD_ARCH

RUN \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "amd64" ]]; then ARCH="x86_64"; fi \
    && echo $ARCH > /etc/apk/arch \
    && apk add --no-cache --update mesa-egl mesa-gles nodejs npm chromium \
    && npm install \
    && chmod +x run.sh

CMD [ "/run.sh" ]
