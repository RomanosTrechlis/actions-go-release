FROM debian:stretch-slim

MAINTAINER Romanos Trechlis <r.trechlis@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
 curl jq git build-essential zip ca-certificates wget

ADD entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]