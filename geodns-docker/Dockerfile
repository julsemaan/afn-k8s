FROM golang:1.22.1-bookworm

ARG GEODNS_REPO=https://github.com/abh/geodns
ARG GEODNS_VERSION=904b19f90ca840cbb1e895d5805f80a8a2580c27

WORKDIR /build

RUN git clone $GEODNS_REPO geodns

WORKDIR geodns

RUN git checkout $GEODNS_VERSION

RUN make linux-build

FROM ubuntu:22.04

COPY --from=0 /build/geodns/dist/geodns-linux-amd64 geodns

RUN mkdir -p dns

RUN mkdir -p /usr/share/GeoIP/

COPY GeoLite2-Country.mmdb /usr/share/GeoIP/

RUN chown root:root /usr/share/GeoIP/GeoLite2-Country.mmdb
RUN chmod 0644 /usr/share/GeoIP/GeoLite2-Country.mmdb
RUN touch /usr/share/GeoIP/GeoLite2-Country.mmdb

COPY geodns.conf dns/

ENTRYPOINT ["/geodns"]


