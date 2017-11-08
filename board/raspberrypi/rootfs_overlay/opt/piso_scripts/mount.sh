#!/bin/sh

set -e

CONFIGFS_HOME=/sys/kernel/config/
GADGET_ROOT=$CONFIGFS_HOME/usb_gadget/g1

add_entry()
{
    ID=$1
    FILE=$2
    CD=$2
    mkdir -p $GADGET_ROOT/functions/mass_storage.$ID/lun.0/

    echo 1 > $GADGET_ROOT/functions/mass_storage.$ID/stall
    echo $CD > $GADGET_ROOT/functions/mass_storage.$ID/lun.0/cdrom
    echo $CD > $GADGET_ROOT/functions/mass_storage.$ID/lun.0/ro
    echo "$FILE" > $GADGET_ROOT/functions/mass_storage.$ID/lun.0/file

    ln -s $GADGET_ROOT/functions/mass_storage.$ID $GADGET_ROOT/configs/c.1/
}

remove_entry()
{
    ID=$1
    rm $GADGET_ROOT/functions/mass_storage.$ID
}

create_device()
{
    echo "Starting device"

    ls /sys/class/udc > $GADGET_ROOT/UDC
}
