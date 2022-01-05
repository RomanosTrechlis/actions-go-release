FROM golang:1.17.5-alpine
MAINTAINER Romanos Trechlis <r.trechlis@gmail.com>

RUN apk add --no-cache curl jq git build-base bash zip

ADD entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]