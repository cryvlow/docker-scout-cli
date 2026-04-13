FROM alpine:3.20

RUN apk add --no-cache bash curl wget tar unzip ca-certificates

WORKDIR /app
COPY . /app

RUN chmod +x install.sh

ENV DOCKER_HOME=/tmp/docker-home
RUN mkdir -p /tmp/docker-home

CMD ["/bin/sh"]