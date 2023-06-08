FROM alpine:latest
VOLUME [ "/data" ]
WORKDIR "/data"
RUN apk add --no-cache tcpdump
ENTRYPOINT ["/usr/bin/tcpdump"]