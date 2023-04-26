FROM ubuntu:22.10

VOLUME [ "/data" ]

# Install zeek
RUN apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y curl wget gnupg2 mailutils \
    && echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.10/ /' | tee /etc/apt/sources.list.d/security:zeek.list \
    && curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.10/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null \
    && apt update \
    && apt install -y zeek-lts

ENV PATH="${PATH}:/opt/zeek/bin"

# # Prevent zeek from capturing some troublesome elements from  network stack
# RUN apt update \
#     && apt upgrade -y \
#     && apt list --upgradable \
#     && apt install -y ethtool \
#     && $(for i in rx tx sg tso ufo gso gro lro; do ethtool -K eth0 $i off; done)

RUN apt update \
    && apt upgrade -y \
    && apt list --upgradable \
    && apt install -y build-essential cmake libnghttp2-dev libbrotli-dev libpcap-dev libz-dev libssl-dev \
    && yes Y | zkg install zeek/mitrecnd/bro-http2 \
    # Use/load the http2 analyzer \
    # Use/load the http2 intel framework extensions \
    && echo "# Enables http2 analyzer" >> /opt/zeek/share/zeek/site/local.zeek \
    && echo "@load http2" >> /opt/zeek/share/zeek/site/local.zeek \
    && echo "# Enables http2 intel framework extensions" >> /opt/zeek/share/zeek/site/local.zeek \
    && echo "@load http2/intel" >> /opt/zeek/share/zeek/site/local.zeek \
    # Enable the extraction of all files \
    && echo "# Enables extraction of all files" >> /opt/zeek/share/zeek/site/local.zeek \
    && echo "@load frameworks/files/extract-all-files" >> /opt/zeek/share/zeek/site/local.zeek

RUN \
    # Ignores checksum check \
    echo "# Ignores checksum check" >> /opt/zeek/share/zeek/site/local.zeek ; \
    echo "redef ignore_checksums=T" >> /opt/zeek/share/zeek/site/local.zeek; \
    # Use JSON format instead of LOG format \
    echo "# Use json log format" >> /opt/zeek/share/zeek/site/local.zeek ; \
    echo "redef LogAscii::use_json=T" >> /opt/zeek/share/zeek/site/local.zeek ;

ENTRYPOINT [ "/opt/zeek/bin/zeek" ]