#!/bin/env bash
input="${1}"

if [[ -z "${input}" ]]; then
    echo " input is missing"
    exit 1;
fi

printf "${input}" | spicy-driver protobuf.spicy