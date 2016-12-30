SUMMARY = "kgio - A ruby gem"
DESCRIPTION = "${SUMMARY}"
GEM_NAME = "kgio"
HOMEPAGE = "http://rubygems.org/gems/kgio"
SECTION = "devel/ruby"
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://COPYING;md5=b52f2d57d10c4f7ee67a7eb9615d5d24"


SRC_URI[md5sum] = "14b9bb02abbeb879c4408dd790742e29"
SRC_URI[sha256sum] = "2804235c990934f03cf5fdacc883f1d6195fe7931f90f1ca6e59a07bf7a0dcf8"

PR = "r0"

inherit rubygems

do_configure() {
  # TODO strange clean-up bug
  # | DEBUG: Executing shell function do_configure
  # | NOTE: make clean
  # | ERROR: oe_runmake failed
  return 0
}
