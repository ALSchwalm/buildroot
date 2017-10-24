#!/bin/sh

set -e

LVM_PARTITION="/dev/mmcblk0p3"
VOLUME_GROUP="VolGroup00"
THINPOOL="thinpool"

if [ -b $LVM_PARTITION ]; then
    modprobe dwc2
    modprobe libcomposite

    if lvs | grep $THINPOOL; then
        exit 0
    else
        pvcreate $LVM_PARTITION || true

        vgcreate $VOLUME_GROUP $LVM_PARTITION || true

        lvcreate -l 100%FREE -T $VOLUME_GROUP/$THINPOOL
    fi
else
    ((
        echo n # Add a new partition
        echo p # Primary partition
        echo 3 # Partition number
        echo   # First sector (Accept default)
        echo   # Last sector (Accept default)
        echo w # Write changes
    ) | fdisk /dev/mmcblk0) || true

    reboot
fi
