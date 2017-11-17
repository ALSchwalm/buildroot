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

mount_iso()
{
    ID=$(basename $1)
    verbose_echo "Mounting iso $1"
    add_entry $ID $1 1
}

unmount_iso()
{
    ID=$(basename $1)
    verbose_echo "Unmounting iso $1"
    remove_entry $ID
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
    mount)
        mount_iso $2
        ;;
    unmount)
        unmount_iso $2
        ;;
    *)
        echo "Usage: iso (mount|unmount) [args...]"
        exit 1
        ;;
esac
