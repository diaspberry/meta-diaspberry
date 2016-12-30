SUMMARY = "rufus-scheduler - A ruby gem"
DESCRIPTION = "${SUMMARY}"
GEM_NAME = "rufus-scheduler"
HOMEPAGE = "http://rubygems.org/gems/rufus-scheduler"
SECTION = "devel/ruby"
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=89f2cdd260a0797248d27c4cee411c32"


SRC_URI[md5sum] = "71f8eab644a09da6aee1160c32278721"
SRC_URI[sha256sum] = "e361f784bbd1b1bbd124c22d2837019a753b776c7c55dc746c38f85494668144"

PR = "r0"

inherit rubygems

do_configure() {
  # TODO strange clean-up bug
  # | DEBUG: Executing shell function do_configure
  # | NOTE: make clean
  # | ERROR: oe_runmake failed
  return 0
}
