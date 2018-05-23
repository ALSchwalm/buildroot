#!/bin/sh

ip addr show dev wlan0 | grep "inet " | cut -d ' ' -f 6  | cut -f 1 -d '/'
