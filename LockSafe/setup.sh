#!/bin/bash

# File variables
encrypted_file="passwords-tst.enc"
plain_file="passwords-tst.txt"  

# Check if there are no arguments
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please specify -p [PIN] to encrypt or -d to decrypt."
    exit 1
fi

# Handling arguments
if [ "$1" == "-p" ]; then
    if [ $# -lt 2 ]; then
        echo "No PIN provided. Please provide a PIN with the -p option."
        exit 1
    else
        touch $plain_file
        echo "test" > $plain_file
        openssl enc -aes-256-cbc -pbkdf2 -in $plain_file -out $encrypted_file -pass pass:$2
        rm -f $plain_file
        echo "File encrypted."
    fi
elif [ "$1" == "-d" ]; then
    if [ $# -lt 2 ]; then
        echo "No PIN provided. Please provide a PIN with the -p option."
        exit 1
    else
        if [ -f $encrypted_file ]; then
            openssl enc -aes-256-cbc -d -pbkdf2 -in $encrypted_file -out $plain_file -pass pass:$2
            echo "File decrypted to $plain_file."
        else
            echo "Encrypted file not found."
            exit 1
        fi
    fi
else
    echo "Invalid option: $1. Use -p [PIN] to encrypt or -d to decrypt."
    exit 1
fi
