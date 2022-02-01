ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY rootfs /

WORKDIR /home/pptruser/app

# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-on-alpine
# Add user so we don't need --no-sandbox.
RUN apk add --no-cache --update su-exec nodejs npm chromium rsync \
    && npm install \
    && chmod +x run.sh \
    && addgroup -S pptruser \
    && adduser -S -g pptruser pptruser \
    && chown -R pptruser:pptruser /home/pptruser

# Run everything after as non-privileged user.
#USER pptruser

CMD [ "./run.sh" ]
