SUMMARY = "Diaspora - A privacy aware distributed social network"
DESCRIPTION = "${SUMMARY}"

RDEPENDS_${PN} = "bash"

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
  file://${PN} \
  file://${PN}.service \
  git://github.com/${PN}/${PN}.git;protocol=git;branch=master \
  "

S = "${WORKDIR}"

SRCREV = "b88f53a3d3fc608b726835437574fee0095ae69f"

do_install() {
  # install diaspora script
  install -d ${D}${bindir}
  install -m 0755 ${WORKDIR}/${PN} ${D}${bindir}/${PN}
  # install systemd unit files
  install -d ${D}${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
  # copy diaspora files to image
  install -d ${D}/home/${PN}/${PN}
  cp -r ${WORKDIR}/git/* ${D}/home/${PN}/${PN}
  chown -R diaspora:diaspora ${D}/home/${PN}
}

inherit useradd systemd
