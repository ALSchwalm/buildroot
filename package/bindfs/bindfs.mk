################################################################################
#
# bindfs
#
################################################################################

BINDFS_VERSION = 1.13.9
BINDFS_SITE = https://bindfs.org/downloads
BINDFS_LICENSE = GPL-2.0
BINDFS_LICENSE_FILES = COPYING
BINDFS_DEPENDENCIES = \
	libfuse

$(eval $(autotools-package))
