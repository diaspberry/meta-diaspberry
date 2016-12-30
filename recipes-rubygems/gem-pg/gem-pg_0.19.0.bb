SUMMARY = "pg - A ruby gem"
DESCRIPTION = "${SUMMARY}"
GEM_NAME = "pg"
HOMEPAGE = "http://rubygems.org/gems/pg"
SECTION = "devel/ruby"
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://LICENSE;md5=837b32593517ae48b9c3b5c87a5d288c"

DEPENDS += " postgresql"
RDEPENDS_${PN} += " postgresql"

SRC_URI[md5sum] = "bb8cc6ecc2856af25f0b549cee857829"
SRC_URI[sha256sum] = "927c41c5d103922c1b2492419802ee92057a5122c7a45064e31b39d08ed8f42e"

PR = "r4"

inherit rubygems

GEM_INSTALL_FLAGS = " \
  --enable-windows-cross \
  --with-${GEM_NAME}-lib=${STAGING_DIR}/${MACHINE}${libdir} \
  --with-${GEM_NAME}-include=${STAGING_DIR}/${MACHINE}${includedir} \
  "
