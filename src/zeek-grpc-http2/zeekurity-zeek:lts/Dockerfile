FROM zeekurity/zeek:lts

VOLUME [ "/data" ]

# install zeek dependencies and extra packages
RUN apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y build-essential cmake libnghttp2-dev libbrotli-dev libpcap-dev libz-dev libssl-dev \
    && yes Y | zkg install zeek/mitrecnd/bro-http2

# configure local.zeek
COPY local-append.zeek /tmp/local-append.zeek
RUN  cat /tmp/local-append.zeek >> /usr/local/zeek/share/zeek/site/local.zeek \
    && rm /tmp/local-append.zeek \
    && zeek_random_seed=`cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-256} | head -n 1)` \
    && sed -i "s/Please change this value./${zeek_random_seed}/g" /usr/local/zeek/share/zeek/site/local.zeek

ENTRYPOINT [ "/usr/local/zeek/bin/zeek" ]