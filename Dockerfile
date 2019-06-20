ARG BASE=alpine:3.9
FROM ${BASE} as base

FROM base as builder
ARG RCLONE_VERSION=v1.48.0
ARG ARCH=amd64

RUN apk -U add ca-certificates wget tzdata

RUN URL=http://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip ; \
  URL=${URL/\/current/} ; \
  cd /tmp \
  && wget -q $URL \
  && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
  && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
  && rm -r /tmp/rclone*

FROM base
RUN apk -U add ca-certificates && rm -rf /var/cache/apk/*
COPY --from=builder /usr/bin/rclone /usr/bin/rclone

VOLUME ["/config"]
VOLUME ["/data"]

ENV RCLONE_CFG=/config/rclone.conf
ENV RCLONE_CMD=sync
ENV RCLONE_SRC=
ENV RCLONE_DST=/data
ENV RCLONE_OPT="--fast-list"
WORKDIR /config

ADD rclone-runner /

ENTRYPOINT ["/rclone-runner"]
