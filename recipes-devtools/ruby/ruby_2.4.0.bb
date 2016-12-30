require ruby.inc

PR = "r1"

LIC_FILES_CHKSUM = " \
  file://COPYING;md5=8a960b08d972f43f91ae84a6f00dcbfb \
  file://BSDL;md5=19aaf65c88a40b508d17ae4be539c4b5 \
  file://GPL;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
  file://LEGAL;md5=daf349ad59dd19bd8c919171bff3c5d6 \
"

SRC_URI[md5sum] = "7e9485dcdb86ff52662728de2003e625"
SRC_URI[sha256sum] = "152fd0bd15a90b4a18213448f485d4b53e9f7662e1508190aa5b702446b29e3d"

# it's unknown to configure script, but then passed to extconf.rb
# maybe it's not really needed as we're hardcoding the result with
# 0001-socket-extconf-hardcode-wide-getaddr-info-test-outco.patch
UNKNOWN_CONFIGURE_WHITELIST += "--enable-wide-getaddrinfo"

PACKAGECONFIG ??= ""
PACKAGECONFIG += "${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'ipv6', '', d)}"

PACKAGECONFIG[valgrind] = "--with-valgrind=yes, --with-valgrind=no, valgrind"
PACKAGECONFIG[gpm] = "--with-gmp=yes, --with-gmp=no, gmp"
PACKAGECONFIG[ipv6] = ",--enable-wide-getaddrinfo,"
