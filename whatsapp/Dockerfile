ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY rootfs /

WORKDIR /home/pptruser/app

ARG BUILD_ARCH

RUN \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "amd64" ]]; then ARCH="x86_64"; fi \
    && echo $ARCH > /etc/apk/arch \
    && apk add --no-cache --update su-exec nodejs npm chromium rsync \
    && npm install \
    && chmod +x run.sh \
    && addgroup -S pptruser \
    && adduser -S -g pptruser pptruser \
    && chown -R pptruser:pptruser /home/pptruser

CMD [ "./run.sh" ]
