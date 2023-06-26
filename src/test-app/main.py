#!/usr/bin/env python3

import sys
import os
import shlex

def exec_todo_create_with(payload_file, server_url):
    line_counter = 0

    with open(payload_file, 'r') as f:
        for line in f:
            title = shlex.quote(f"Title {line_counter} - {line}")
            command = f'./bin/GrpcTodoClient/GrpcTodoClient create --server {server_url} --title {title} --description "Description {line_counter}"'
            print(f'Executing command: {command}')
            os.system(command)


def main():

    # check server variable GRPC_TODO_SERVER is set
    if 'GRPC_TODO_SERVER' not in os.environ:
        print('GRPC_TODO_SERVER environment variable not set. Set it ot the server URL and restart the app.')
        sys.exit(1)

    # check server variable GRPC_TODO_SERVER is set
    if 'GRPC_TODO_PAYLOAD_FILE' not in os.environ:
        print('GRPC_TODO_PAYLOAD_FILE environment variable not set. Set it to a text file with SQLi injections.')
        sys.exit(1)

    # reads a text file and iterates over each line
    server_url = os.environ['GRPC_TODO_SERVER']
    payload_file = os.environ['GRPC_TODO_PAYLOAD_FILE'] # './payloads/owap-positive-waf-matches.txt'
    command = exec_todo_create_with(payload_file, server_url)


if __name__ == '__main__':
    main()
    sys.exit(0)