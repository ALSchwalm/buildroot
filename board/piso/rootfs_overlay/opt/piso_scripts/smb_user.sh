#!/bin/sh

# Enable the user for samba
(echo "$2"; echo "$2") | smbpasswd -a "$1"
smbpasswd -e "$1"
