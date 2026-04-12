FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache bash curl git tar unzip ca-certificates

COPY install.sh /app/install.sh
COPY README.md /app/README.md

RUN chmod +x /app/install.sh

CMD ["/bin/sh"]