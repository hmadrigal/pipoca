#/usr/bin/env bash

# set -x

_pcap_file="gRPC-TodoApp-Over-HTTP.pcap"

# grpc-non-tls-dotnet.pcap
# gRPC-TodoApp-Over-HTTP.pcap

rm -rf *.log *.json extract_files/

zeek -C -r "${_pcap_file}" main.zeek  > main.log

for f in *.log; do

    [ -f "$f" ] || break
    jsonfile="${f/.log/.json}"
    printf "" > "${jsonfile}"
    echo "[" >> "${jsonfile}"
    sed ':a;N;$!ba;s/\n/, \n/g' "$f" >> "${jsonfile}"
    echo "]" >> "${jsonfile}"
    echo "$( cat "${jsonfile}" | jq )" > "${jsonfile}"

done
