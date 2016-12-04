FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "gdk-pixbuf-native"
PRINC = "8"

FILES_${PN} += "${systemd_unitdir}/*"
SRC_URI += " \
  file://psplash-start.service \
  file://psplash-quit.service \
  "

SPLASH_IMAGES = "file://psplash-poky-img.png;outsuffix=default"

do_install_append () {
  systemd_etcdir=/etc/systemd/system
  install -d ${D}${systemd_etcdir}/multi-user.target.wants
  install -d ${D}${systemd_etcdir}/sysinit.target.wants
  install -d ${D}${systemd_unitdir}/system
  install -m 644 ${WORKDIR}/*.service ${D}/${systemd_unitdir}/system

  # since we have to enable both services
  ln -s /${systemd_unitdir}/system/${PN}-start.service \
    ${D}${systemd_etcdir}/sysinit.target.wants/${PN}-start.service
  ln -s /${systemd_unitdir}/system/${PN}-quit.service \
    ${D}${systemd_etcdir}/multi-user.target.wants/${PN}-quit.service
}
