#!/bin/sh

set -e

LVM_PARTITION="/dev/mmcblk0p3"
VOLUME_GROUP="VolGroup00"
THINPOOL="thinpool"
CONFIGFS_HOME="/sys/kernel/config/"
GADGET_ROOT="$CONFIGFS_HOME/usb_gadget/g1"

init_configfs()
{
    echo "Initializing ConfigFS gadget root in '$GADGET_ROOT'"

    local VENDOR_ID=0x1d6b  # Linux Foundation
    local PRODUCT_ID=0x0104 # Multifunction Composite Gadget
    local DEVICE_BCD=0x0100 # v1.0.0
    local USB_BCD=0x0200    # USB2

    echo $VENDOR_ID > $GADGET_ROOT/idVendor
    echo $PRODUCT_ID > $GADGET_ROOT/idProduct
    echo $DEVICE_BCD > $GADGET_ROOT/bcdDevice
    echo $USB_BCD > $GADGET_ROOT/bcdUSB

    mkdir -p $GADGET_ROOT/strings/0x409

    local SERIAL_NUMBER="0000000000000000"
    local MANUFACTURER="Adam Schwalm"
    local PRODUCT="USB MultiTool"

    echo $SERIAL_NUMBER > $GADGET_ROOT/strings/0x409/serialnumber
    echo $MANUFACTURER > $GADGET_ROOT/strings/0x409/manufacturer
    echo $PRODUCT > $GADGET_ROOT/strings/0x409/product

    mkdir -p $GADGET_ROOT/configs/c.1/strings/0x409

    local MAX_POWER=250
    local CONFIGURATION="Config 1"

    echo $MAX_POWER > $GADGET_ROOT/configs/c.1/MaxPower
    echo $CONFIGURATION > $GADGET_ROOT/configs/c.1/strings/0x409/configuration
}


if [ -b $LVM_PARTITION ]; then
    modprobe dwc2
    modprobe libcomposite

    if ! (lvs | grep $THINPOOL) ; then
        pvcreate $LVM_PARTITION || true

        vgcreate $VOLUME_GROUP $LVM_PARTITION || true

        lvcreate -l 100%FREE -T $VOLUME_GROUP/$THINPOOL
    fi

    vgchange -a y $VOLUME_GROUP

    # Get configfs up and running
    mount none /sys/kernel/config -t configfs
    mkdir -p $GADGET_ROOT

    init_configfs
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
