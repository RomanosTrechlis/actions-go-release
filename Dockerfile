FROM golang:1.17.5-alpine
MAINTAINER Romanos Trechlis <r.trechlis@gmail.com>

RUN apk add --no-cache curl git build-base bash zip

ADD entrypoint.sh /entrypoint.sh
ADD build.sh /build.sh
ENTRYPOINT ["/entrypoint.sh"]