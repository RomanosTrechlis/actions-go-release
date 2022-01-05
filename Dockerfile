FROM golang:1.17.5-alpine
MAINTAINER Romanos Trechlis <r.trechlis@gmail.com>

RUN apk add --no-cache curl git build-base bash zip

ADD entrypoint.sh /entrypoint.sh
ADD build.sh /build.sh

RUN ["chmod", "+x", "/entrypoint.sh"]
RUN ["chmod", "+x", "/build.sh"]
ENTRYPOINT ["/entrypoint.sh"]