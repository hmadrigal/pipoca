#!/usr/bin/env python3

import sys



def main():
    # reads a text file and iterates over each line
    with open('./payloads/owap-positive-waf-matches.txt', 'r') as f:
        for line in f:
            print(line)


if __name__ == '__main__':
    main()
    sys.exit(0)