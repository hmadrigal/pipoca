#!/bin/env bash
input="${1}"

if [[ -z "${input}" ]]; then
    echo " input is missing"
    exit 1;
fi

printf "${input}" | spicy-driver --debug --show-backtraces --report-times --skip-dependencies protobuf.spicy

# Example
# ./protobuf.sh '\x0a\x2f\x0a\x08\x4a\x6f\x68\x6e\x20\x44\x6f\x65\x10\x01\x1a\x10\x6a\x6f\x68\x6e\x40\x65\x78\x61\x6d\x70\x6c\x65\x2e\x63\x6f\x6d\x22\x0f\x0a\x0b\x31\x31\x31\x2d\x32\x32\x32\x2d\x33\x33\x33\x10\x01\x0a\x1e\x0a\x08\x4a\x61\x6e\x65\x20\x44\x6f\x65\x10\x02\x1a\x10\x6a\x61\x6e\x65\x40\x65\x78\x61\x6d\x70\x6c\x65\x2e\x63\x6f\x6d'
# See https://protobuf-decoder.netlify.app/
#  0a 2f 0a 08 4a 6f 68 6e 20 44 6f 65 10 01 1a 10 6a 6f 68 6e 40 65 78 61 6d 70 6c 65 2e 63 6f 6d 22 0f 0a 0b 31 31 31 2d 32 32 32 2d 33 33 33 10 01 0a 1e 0a 08 4a 61 6e 65 20 44 6f 65 10 02 1a 10 6a 61 6e 65 40 65 78 61 6d 70 6c 65 2e 63 6f 6d