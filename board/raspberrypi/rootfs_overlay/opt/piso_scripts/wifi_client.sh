#!/bin/sh

(
    echo "remove_network 0"
    echo "enable $1"
) | wpa_cli
