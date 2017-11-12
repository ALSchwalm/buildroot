#!/bin/sh

set -e

CONFIGFS_HOME=/sys/kernel/config/
GADGET_ROOT=$CONFIGFS_HOME/usb_gadget/g1

add_entry()
{
    ID=$1
    FILE=$2
    CD=$3

    deactivate_udc
    mkdir -p $GADGET_ROOT/functions/mass_storage.$ID/lun.0/

    echo 1 > $GADGET_ROOT/functions/mass_storage.$ID/stall
    echo $CD > $GADGET_ROOT/functions/mass_storage.$ID/lun.0/cdrom

    # This seems like a bug. If 'ro' has already been set, you cannot
    # change it (resource busy) even if UDC is inactive and the
    # config is removed. For now just suppress the error.
    echo $CD 2> $GADGET_ROOT/functions/mass_storage.$ID/lun.0/ro

    echo "$FILE" > $GADGET_ROOT/functions/mass_storage.$ID/lun.0/file
    ln -s $GADGET_ROOT/functions/mass_storage.$ID $GADGET_ROOT/configs/c.1/

    activate_udc
}

remove_entry()
{
    ID=$1
    deactivate_udc
    rm $GADGET_ROOT/configs/c.1/mass_storage.$ID
    activate_udc
}

deactivate_udc()
{
    # Suppress error if already inactive
    echo "" 2> $GADGET_ROOT/UDC
}

activate_udc()
{
    ls /sys/class/udc > $GADGET_ROOT/UDC
}
