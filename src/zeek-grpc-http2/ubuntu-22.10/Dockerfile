FROM ubuntu:22.10

VOLUME [ "/data" ]
WORKDIR /data

# Install zeek
RUN apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y curl wget gnupg2 mailutils \
    && echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.10/ /' | tee /etc/apt/sources.list.d/security:zeek.list \
    && curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.10/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null \
    && apt update \
    && apt install -y zeek-lts

# Disables warning about port change
RUN echo -e "\n# Starting with Zeek 5.2 changes from 47760 to 27760. \nZeekPort = 27760\n"  >> /opt/zeek/etc/zeekctl.cfg

ENV PATH="${PATH}:/opt/zeek/bin"

# Prevent zeek from capturing some troublesome elements from network stack
RUN apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y ethtool \
    && export network_devices=$(nmcli device status |  sed -n '1d;p' | grep 'ethernet' | awk '{ print $1}') \
    && for nd in "$network_devices"; do $(for i in rx tx sg tso ufo gso gro lro; do ethtool -K $nd $i off; done); done \
    && unset network_devices

# Install HTTP2 plugin
RUN apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y build-essential cmake libnghttp2-dev libbrotli-dev libpcap-dev libz-dev libssl-dev \
    && zkg autoconfig --force \
    && zkg install --force zeek/mitrecnd/bro-http2 \
    && zkg refresh

# Configure local.zeek
COPY local-append.zeek /tmp/local-append.zeek
RUN  cat /tmp/local-append.zeek >> /opt/zeek/share/zeek/site/local.zeek \
    && rm /tmp/local-append.zeek \
    && zeek_random_seed=`cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-256} | head -n 1` \
    && sed -i "s/Please change this value./${zeek_random_seed}/g" /opt/zeek/share/zeek/site/local.zeek

ENTRYPOINT [ "/opt/zeek/bin/zeek" ]