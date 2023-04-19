FROM zeekurity/zeek:lts

RUN  \
    # Install dependencies \
    apt update && \
    apt upgrade -y && \
    apt list --upgradable && \
    apt install -y build-essential cmake libnghttp2-dev libbrotli-dev libpcap-dev libz-dev libssl-dev && \
    yes Y | zkg install zeek/mitrecnd/bro-http2 ; \
    # Use/load the http2 analyzer \
    # Use/load the http2 intel framework extensions \
    echo "# Enables http2 analyzer" >> /usr/local/zeek/share/zeek/site/local.zeek ; \
    echo "@load http2" >> /usr/local/zeek/share/zeek/site/local.zeek ; \
    echo "# Enables http2 intel framework extensions" >> /usr/local/zeek/share/zeek/site/local.zeek ; \
    echo "@load http2/intel" >> /usr/local/zeek/share/zeek/site/local.zeek ; \
    # Enable the extraction of all files \
    echo "# Enables extraction of all files" >> /usr/local/zeek/share/zeek/site/local.zeek ; \
    echo "@load frameworks/files/extract-all-files" >> /usr/local/zeek/share/zeek/site/local.zeek

# TODO:
#   - Allow docker files to be in JSON format for readability
#   - Try to capture files from HTTP/2 (1st try with files from  HTTP/1.1)