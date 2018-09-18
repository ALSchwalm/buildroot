#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Cleanup a few things
if [ -d ${TARGET_DIR}/usr/libexec/ctdb/tests ]; then
    rm -r "${TARGET_DIR}/usr/libexec/ctdb/tests"
fi

if [ -d ${TARGET_DIR}/usr/share/ctdb/tests ]; then
    rm -r "${TARGET_DIR}/usr/share/ctdb/tests"
fi

if [ -d ${TARGET_DIR}/usr/lib/python2.7 ]; then
    rm -r "${TARGET_DIR}//usr/lib/python2.7"
fi

find "${TARGET_DIR}/lib/firmware/brcm" -type f \
     -not -name 'brcmfmac43430-sdio.txt' \
     -not -name 'brcmfmac43430-sdio.bin' \
     -delete

# We will start these manually when the user starts wifi
rm "${TARGET_DIR}/etc/init.d/S91smb" || true

# Ensure the scripts are executable
chmod +x "${TARGET_DIR}/opt/piso_scripts"/*
chmod +x "${TARGET_DIR}/etc/init.d/S02usb"
