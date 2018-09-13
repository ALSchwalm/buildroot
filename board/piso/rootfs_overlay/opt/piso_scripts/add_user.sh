#!/bin/sh

(echo "$2"; echo "$2") | adduser "$1" --home "/user-mnt" --no-create-home

# Enable the user for samba
(echo "$2"; echo "$2") | smbpasswd -a "$1"
smbpasswd -e "$1"
