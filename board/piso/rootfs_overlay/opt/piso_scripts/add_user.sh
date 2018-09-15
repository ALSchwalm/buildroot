#!/bin/sh

(echo "$2"; echo "$2") | adduser "$1" --home "/user-mnt" --no-create-home
