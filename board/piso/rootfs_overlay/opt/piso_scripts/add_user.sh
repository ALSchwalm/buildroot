#!/bin/sh

# Remove any existing user that was created with a previous config
existing=$(cat /etc/passwd | grep '/user-mnt' | cut -f 1 -d:)
if [ $? -eq 0 ]; then
    deluser $existing
fi

(echo "$2"; echo "$2") | adduser "$1" --home "/user-mnt" --no-create-home
