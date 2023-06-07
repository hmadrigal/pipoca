#/usr/bin/env bash

set -x

# if [ -d ./build/ ]; then 
#     rm -rf ./build/
# fi

./configure --enable-debug 

# make clean 

make 

echo "Exit Code ${?}"
