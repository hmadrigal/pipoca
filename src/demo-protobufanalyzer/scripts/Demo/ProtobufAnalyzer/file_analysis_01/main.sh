#/usr/bin/env bash

rm -rf *.log *.json extract_files/
zeek -C -r grpc-non-tls-dotnet.pcap main.zeek  > main.log

for f in *.log; do

    [ -f "$f" ] || break
    jsonfile="${f/.log/.json}"
    printf "" > "${jsonfile}"
    echo "[" >> "${jsonfile}"
    sed ':a;N;$!ba;s/\n/, \n/g' "$f" >> "${jsonfile}"
    echo "]" >> "${jsonfile}"
    echo "$( cat "${jsonfile}" | jq )" > "${jsonfile}"

done
