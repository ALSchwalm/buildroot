#!/bin/sh

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

if ! grep -qE '^dtoverlay=dwc2' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'dtoverlay=dwc2' to config.txt"
    echo "dtoverlay=dwc2" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qE '^dtoverlay=pi3-disable-bt' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'dtoverlay=pi3-disable-bt' to config.txt"
    echo "dtoverlay=pi3-disable-bt" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qE '^dtoverlay=mmc,overclock_50=63' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'dtoverlay=mmc,overclock_50=63' to config.txt"
    echo "dtoverlay=mmc,overclock_50=63" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'enable_uart=1' to config.txt"
    echo "enable_uart=1" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qE '^dtparam=spi=on' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'dtparam=spi=on' to config.txt"
    echo "dtparam=spi=on" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qE '^boot_delay=0' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'boot_delay=0' to config.txt"
    echo "boot_delay=0" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qE '^initial_turbo=10' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
    echo "Adding 'initial_turbo=10' to config.txt"
    echo "initial_turbo=10" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

rm "${BINARIES_DIR}/rpi-firmware/cmdline.txt"
echo "root=/dev/mmcblk0p2 ro rootwait rootfstype=ext4 raid=noautodetect console=tty1 console=ttyAMA0,115200" \
     > "${BINARIES_DIR}/rpi-firmware/cmdline.txt"

case "${2}" in
	--add-pi3-miniuart-bt-overlay)
	if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		echo "Adding 'dtoverlay=pi3-miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi3 ttyAMA0 serial console
dtoverlay=pi3-miniuart-bt
__EOF__
	fi
	;;
	--aarch64)
	# Run a 64bits kernel (armv8)
	sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
	if ! grep -qE '^arm_control=0x200' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_control=0x200
__EOF__
	fi

	# Enable uart console
	if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable rpi3 ttyS0 serial console
enable_uart=1
__EOF__
	fi
	;;
esac

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
