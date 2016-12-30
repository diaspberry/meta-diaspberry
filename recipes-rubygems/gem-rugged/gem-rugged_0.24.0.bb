SUMMARY = "rugged - A ruby gem"
DESCRIPTION = "${SUMMARY}"
GEM_NAME = "rugged"
HOMEPAGE = "http://rubygems.org/gems/rugged"
SECTION = "devel/ruby"
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://vendor/libgit2/deps/http-parser/LICENSE-MIT;md5=20d989143ee48a92dacde4f06bbcb59a"

DEPENDS = "libgit2"
RDEPENDS_${PN} = "libgit2"

SRC_URI[md5sum] = "9f86c5a2801b6727aa88a302dc018a2f"
SRC_URI[sha256sum] = "d9c02710c14af233572baa3b96b9b62ce222f1a9197623e355eddaa2e06ad43a"

PR = "r2"

inherit rubygems

GEM_INSTALL_FLAGS = " \
  --with-${GEM_NAME}-lib=${STAGING_DIR}/${MACHINE}${libdir} \
  --with-${GEM_NAME}-include=${STAGING_DIR}/${MACHINE}${includedir} \
  "
