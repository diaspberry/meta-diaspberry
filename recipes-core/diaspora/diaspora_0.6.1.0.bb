require dependencies.inc

SUMMARY = "Diaspora - A privacy aware distributed social network"
DESCRIPTION = "${SUMMARY}"

PR="r3"

DEPENDS = " bash"
# bundler ist not installed via the Gemfile
RDEPENDS_${PN} += " \
  bash resolvconf imagemagick redis \
  postgresql git curl cmake ghostscript \
  "

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ed1dca40ee0852c630f19c06fdecf6bc"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} = "-M -g ${PN} -r -d /home/${PN} -s /bin/bash ${PN}"
GROUPADD_PARAM_${PN} = "-r ${PN}"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

FILES_${PN} += " \
  ${systemd_unitdir}/* \
  /home/${PN}/* \
  "

SRC_URI = "file://LICENSE \
  git://github.com/${PN}/${PN}.git;protocol=git;tag=v${PV} \
  file://resolv.conf \
  file://${PN} \
  file://${PN}.service \
  "

S = "${WORKDIR}"

RAILS_ENV = "production"

do_install() {
  # install dns nameserver
  install -d ${D}{sysconfdir}
  install -m 0644 ${S}/resolv.conf ${D}{sysconfdir}/resolv.conf

  # install diaspora script
  install -d ${D}${bindir}
  install -m 0755 ${S}/${PN} ${D}${bindir}/${PN}

  # install systemd unit files
  install -d ${D}${systemd_unitdir}/system
  install -m 0644 ${S}/${PN}.service ${D}${systemd_unitdir}/system

  # copy diaspora files to image
  install -d ${D}/home/${PN}/${PN}
  cp -r ${S}/git/* ${D}/home/${PN}/${PN}
  chown -R diaspora:diaspora ${D}/home/${PN}
}

inherit useradd systemd
