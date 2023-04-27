Build the container with the following commands:
```shell
./main.sh --build
```

Run the container with the following commands:
```shell
./main.sh --run --entrypoint /bin/bash
```

Into the container, run the following commands:
```shell
rm -rf *.log *.json extract_files/*; ZEEK_LOG_SUFFIX=json zeek -C -r http2-data-reassembly.pcap /usr/local/zeek/share/zeek/site/local.zeek
```