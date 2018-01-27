#!/bin/sh

set -e

_VERBOSE=0

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/mount.sh"

verbose_echo()
{
    if [[ $_VERBOSE -eq 1 ]]; then
        echo "$@"
    fi
}

mount_external_vdrive()
{
    VOLUME_PATH="/dev/VolGroup00/$1"
    verbose_echo "Adding entry for volume $VOLUME_PATH"
    add_entry $1 $VOLUME_PATH 0
}

unmount_external_vdrive()
{
    verbose_echo "Removing entry with ID=$1"
    remove_entry $1
}

mount_internal_vdrive_basic()
{
    VOLUME_PATH="/dev/VolGroup00/$1"

    LOOPBACK_PATH=$(losetup -f)

    verbose_echo "Creating loopback devices for $VOLUME_PATH"
    losetup -fPL $VOLUME_PATH

    verbose_echo "Scanning partitions of $LOOPBACK_PATH"

    # Force (for real) a scan for partitions
    partprobe $LOOPBACK_PATH

    verbose_echo "Locating loopback devices for partitions"

    LOOPBACK_SUFFIX="p"
    find /dev -wholename "$LOOPBACK_PATH$LOOPBACK_SUFFIX*"
}

# Given a volume name and a mount point, mount each partition
# of the drive and scan the partitions for ISOS. Each located
# iso is printed.
mount_internal_vdrive()
{
    PARTITIONS=$(mount_internal_vdrive_basic $1)
    MOUNTPOINT=$2

    verbose_echo "Located partitions: $PARTITIONS"

    for PARTITION in ${PARTITIONS}; do
        PART_MOUNT="$MOUNTPOINT/$(basename $PARTITION)"

        verbose_echo "Mounting $PARTITION to $PART_MOUNT"
        mkdir -p $PART_MOUNT
        mount $PARTITION $PART_MOUNT > /dev/null 2>&1

        if [ -d "$PART_MOUNT/ISOS" ]; then
            find "$PART_MOUNT/ISOS/" -type f
        fi
    done
}

# unmount_internal_vdrive_basic()
# {
#     #TODO: undo losetup(?)
# }

unmount_internal_vdrive()
{
    MOUNTPOINT=$1

    for PARTITION in ${MOUNTPOINT}/*; do
        verbose_echo "Unmounting $PARTITION"
        if [[ $_VERBOSE -eq 1 ]]; then
            umount $PARTITION || true
        else
            umount $PARTITION > /dev/null 2>&1 || true
        fi
    done
}

while getopts ":v" OPTION
do
    case $OPTION in
        v)
            _VERBOSE=1
            shift
            ;;
    esac
done

case $1 in
    mount-internal-basic)
        mount_internal_vdrive_basic $2
        ;;
    unmount-internal-basic)
        # unmount_internal_vdrive_basic $2
        ;;
    mount-internal)
        mount_internal_vdrive $2 $3
        ;;
    unmount-internal)
        unmount_internal_vdrive $2
        ;;
    mount-external)
        mount_external_vdrive $2
        ;;
    unmount-external)
        unmount_external_vdrive $2
        ;;
    *)
        echo "Usage: vdrive (mount-internal|unmount-internal) [args...]"
        exit 1
        ;;
esac
