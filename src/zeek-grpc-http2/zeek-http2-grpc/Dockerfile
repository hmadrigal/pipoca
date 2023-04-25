FROM zeekurity/zeek:lts

VOLUME [ "/data" ]

COPY local-append.zeek /tmp/local-append.zeek

RUN  \
    # Install dependencies \
    apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y build-essential cmake libnghttp2-dev libbrotli-dev libpcap-dev libz-dev libssl-dev \
    && yes Y | zkg install zeek/mitrecnd/bro-http2  \
    && cat /tmp/local-append.zeek >> /usr/local/zeek/share/zeek/site/local.zeek \
    && rm /tmp/local-append.zeek

ENTRYPOINT [ "/usr/local/zeek/bin/zeek" ]