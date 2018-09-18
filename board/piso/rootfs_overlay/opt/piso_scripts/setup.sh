#!/bin/sh

set -e

LVM_PARTITION="/dev/mmcblk0p3"
VOLUME_GROUP="VolGroup00"
THINPOOL="thinpool"
CONFIGFS_HOME="/sys/kernel/config/"
GADGET_ROOT="$CONFIGFS_HOME/usb_gadget/g1"


if [ -b $LVM_PARTITION ]; then
    modprobe dwc2
    modprobe spi-bcm2835
    modprobe spidev
    modprobe libcomposite
    modprobe fuse

    if ! (lvs | grep $THINPOOL) ; then
        pvcreate $LVM_PARTITION || true

        vgcreate $VOLUME_GROUP $LVM_PARTITION || true

        lvcreate -l 100%FREE -T $VOLUME_GROUP/$THINPOOL
    fi

    sysctl -p /etc/sysctl.conf

    vgchange -a y $VOLUME_GROUP

    # Get configfs up and running
    mkdir -p $GADGET_ROOT
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
