FROM zeekurity/zeek:lts

# Enable the extraction of all files
RUN echo "@load frameworks/files/extract-all-files" >> /usr/local/zeek/share/zeek/site/local.zeek

# Install the bro-http2 plugin
RUN apt update && \
    apt upgrade -y && \
    apt list --upgradable && \
    apt install -y build-essential cmake libnghttp2-dev libbrotli-dev libpcap-dev libz-dev libssl-dev && \
    zkg install zeek/mitrecnd/bro-http2