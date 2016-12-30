SUMMARY = "raindrops - A ruby gem"
DESCRIPTION = "${SUMMARY}"
GEM_NAME = "raindrops"
HOMEPAGE = "http://rubygems.org/gems/raindrops"
SECTION = "devel/ruby"
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://COPYING;md5=b52f2d57d10c4f7ee67a7eb9615d5d24"


SRC_URI[md5sum] = "2b175ba8fd24aec04ba6c16231534af7"
SRC_URI[sha256sum] = "54ddae268a85575ab70d2309280702bf822463dbf56c7e8251073f19fd76b6e6"

PR = "r1"

inherit rubygems

do_configure() {
  # TODO strange clean-up bug
  # | DEBUG: Executing shell function do_configure
  # | NOTE: make clean
  # | ERROR: oe_runmake failed
  return 0
}
