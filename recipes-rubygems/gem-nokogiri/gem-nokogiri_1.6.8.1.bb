SUMMARY = "nokogiri - A ruby gem"
DESCRIPTION = "${SUMMARY}"
GEM_NAME = "nokogiri"
HOMEPAGE = "http://rubygems.org/gems/nokogiri"
SECTION = "devel/ruby"
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=f100868abef138a76488b1b0a8ccd4a0"

SRC_URI[md5sum] = "3f14846b6dd22055302acbf3d4d77c49"
SRC_URI[sha256sum] = "92814a7ff672e42b60fd5c02d75b62ab8fd2df3afbac279cc8dadac3c16bbd10"

PR = "r2"

inherit rubygems

GEM_INSTALL_FLAGS = " \
  --use-system-libraries \
  --with-${GEM_NAME}-lib=${STAGING_DIR}/${MACHINE}${libdir} \
  --with-${GEM_NAME}-include=${STAGING_DIR}/${MACHINE}${includedir} \
  "
