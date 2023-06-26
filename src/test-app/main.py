#!/usr/bin/env python3

import sys

def main():

    # check server variable GRPC_TODO_SERVER is set
    if 'GRPC_TODO_SERVER' not in os.environ:
        print('GRPC_TODO_SERVER environment variable not set. Set it ot the server URL and restart the app.')
        sys.exit(1)

    # reads a text file and iterates over each line
    with open('./payloads/owap-positive-waf-matches.txt', 'r') as f:
        for line in f:
            print(line)


if __name__ == '__main__':
    main()
    sys.exit(0)