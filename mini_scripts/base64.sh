#!/bin/bash

# Check if an argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 [-d] string"
    echo "  -d    decode the input string"
    echo "  If -d is not provided, the string will be encoded"
    exit 1
fi

# Check if the first argument is -d for decoding
if [ "$1" = "-d" ]; then
    # Ensure we have a string to decode
    if [ $# -lt 2 ]; then
        echo "Error: No string provided for decoding"
        exit 1
    fi
    echo -n "$2" | base64 --decode
else
    # Encode the provided string
    echo -n "$1" | base64
fi
