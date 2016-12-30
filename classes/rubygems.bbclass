#
# Copyright (C) 2014 Wind River Systems, Inc.
#
# Copied from http://git.yoctoproject.org/cgit/cgit.cgi/meta-cloud-services/plain/classes/ruby.bbclass
# Modified by Lukas Matt <lukas@zauberstuhl.de>
#
DEPENDS += " \
    ruby-native \
"
RDEPENDS_${PN} += " \
    ruby \
"

GEM_SRC_TLD ?= "http://rubygems.org"
GEM_SRC = "${GEM_SRC_TLD}/gems"

GEM_NAME ?= "${@get_gem_name_from_bpn(d)}"
GEM_VERSION ?= "${PV}"

GEM_FILENAME = "${GEM_NAME}-${GEM_VERSION}.gem"
SRC_URI = "${GEM_SRC}/${GEM_FILENAME}"
GEMPREFIX = "gem-"

S = "${WORKDIR}/${GEM_NAME}-${GEM_VERSION}"

GEM_BUILT_FILE = "${S}/${GEM_FILENAME}"
GEMSPEC ?= "${S}/${GEM_NAME}.gemspec"

GEM_INSTALL_FLAGS ?= ""

# skip splitting gem files into debug pkg
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

def get_gem_name_from_bpn(d):
    bpn = (d.getVar('BPN', True) or "")
    gemPrefix = (d.getVar('GEMPREFIX', True) or "")
    if bpn.startswith(gemPrefix):
        gemName = bpn[len(gemPrefix):]
    else:
        gemName = bpn
    return gemName

#${PN}_do_compile[depends] += "ruby-native:do_populate_sysroot"

def get_rubyversion(p):
    import re
    from os.path import isfile
    import subprocess
    found_version = "SOMETHING FAILED!"

    cmd = "%s/ruby" % p

    if not isfile(cmd):
       return found_version

    version = subprocess.Popen([cmd, "--version"], stdout=subprocess.PIPE).communicate()[0]
    
    r = re.compile("ruby ([0-9]+\.[0-9]+\.[0-9]+)*")
    m = r.match(version)
    if m:
        found_version = m.group(1)

    return found_version

def get_rubygemslocation(p):
    import re
    from os.path import isfile
    import subprocess
    found_loc = "SOMETHING FAILED!"

    cmd = "%s/gem" % p

    if not isfile(cmd):
       return found_loc

    loc = subprocess.Popen([cmd, "env"], stdout=subprocess.PIPE).communicate()[0]

    r = re.compile(".*\- (/usr.*/ruby/gems/.*)")
    for line in loc.split('\n'):
        m = r.match(line)
        if m:
            found_loc = m.group(1)
            break

    return found_loc

def get_rubygemsversion(p):
    import re
    from os.path import isfile
    import subprocess
    found_version = "SOMETHING FAILED!"

    cmd = "%s/gem" % p

    if not isfile(cmd):
       return found_version

    version = subprocess.Popen([cmd, "env", "gemdir"], stdout=subprocess.PIPE).communicate()[0]
    
    r = re.compile(".*([0-9]+\.[0-9]+\.[0-9]+)$")
    m = r.match(version.decode("utf-8"))
    if m:
        found_version = m.group(1)

    return found_version

RUBY_VERSION ?= "${@get_rubyversion("${STAGING_BINDIR_NATIVE}")}"
RUBY_GEM_DIRECTORY ?= "${@get_rubygemslocation("${STAGING_BINDIR_NATIVE}")}"
RUBY_GEM_VERSION ?= "${@get_rubygemsversion("${STAGING_BINDIR_NATIVE}")}"

export GEM_HOME = "${STAGING_DIR_NATIVE}/usr/lib/ruby/gems/${RUBY_GEM_VERSION}"

RUBY_COMPILE_FLAGS ?= 'LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8"'

rubygems_gen_extconf_fix() {
  cat<<EOF>>append_header
#RbConfig::MAKEFILE_CONFIG['CPPFLAGS'] = ENV['CPPFLAGS'] if ENV['CPPFLAGS']
\$CPPFLAGS = ENV['CPPFLAGS'] if ENV['CPPFLAGS']
RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']
RbConfig::MAKEFILE_CONFIG['LD'] = ENV['LD'] if ENV['LD']
RbConfig::MAKEFILE_CONFIG['CFLAGS'] = ENV['CFLAGS'] if ENV['CFLAGS']
RbConfig::MAKEFILE_CONFIG['LDFLAGS'] = ENV['LDFLAGS'] if ENV['LDFLAGS']
RbConfig::MAKEFILE_CONFIG['CXXFLAGS'] = ENV['CXXFLAGS'] if ENV['CXXFLAGS']
EOF
  sysroot_ruby=${STAGING_INCDIR}/ruby-${RUBY_GEM_VERSION}
  ruby_arch=`ls -1 ${sysroot_ruby} |grep -v ruby |tail -1 2> /dev/null`
  cat<<EOF>append_footer
system("perl -p -i -e 's#^topdir.*#topdir = ${sysroot_ruby}#' Makefile")
system("perl -p -i -e 's#^hdrdir.*#hdrdir = ${sysroot_ruby}#' Makefile")
system("perl -p -i -e 's#^arch_hdrdir.*#arch_hdrdir = ${sysroot_ruby}/\\\\\$(arch)#' Makefile")
system("perl -p -i -e 's#^arch =.*#arch = ${ruby_arch}#' Makefile")
system("perl -p -i -e 's#^LIBPATH =.*#LIBPATH = -L.#' Makefile")
system("perl -p -i -e 's#^dldflags =.*#dldflags = ${LDFLAGS}#' Makefile")
EOF
}

do_unpack_gem() {
  cd ${WORKDIR} && gem unpack -V ${GEM_FILENAME}
}
addtask unpack_gem after do_unpack before do_patch

do_generate_spec() {
  gem spec -V --ruby ${WORKDIR}/${GEM_FILENAME} > ${GEMSPEC}
}
addtask generate_spec after do_unpack_gem before do_patch

rubygems_do_patch() {
  GEM_EXTCONF="$(find ${S} -name extconf.rb |head -n1)"
  if [ -f ${GEM_EXTCONF} -a ! -f ${GEM_EXTCONF}.orig ]; then
    cp ${GEM_EXTCONF} ${GEM_EXTCONF}.orig
    # create new header
    grep -E '^require' ${GEM_EXTCONF} > append_header || {
      bbwarn "No require flags found in extconf.rb"
    }
    rubygems_gen_extconf_fix
    # remove old header
    sed -i "s/^require\s.*//; s/^#!.*//" ${GEM_EXTCONF}
    # append new header/footer
    cat append_header > ${GEM_EXTCONF}.new
    cat ${GEM_EXTCONF} >> ${GEM_EXTCONF}.new
    cat append_footer >> ${GEM_EXTCONF}.new
    mv ${GEM_EXTCONF}.new ${GEM_EXTCONF}
  fi
}

rubygems_do_compile() {
  ${RUBY_COMPILE_FLAGS} gem build ${GEMSPEC} || {
    bbwarn "Building ${GEMPREFIX}${GEM_NAME} from spec reports some errors!"
  }
}

rubygems_do_install() {
  gem install \
    --ignore-dependencies --local --env-shebang \
    --install-dir ${D}/${libdir}/ruby/gems/${RUBY_GEM_VERSION}/ \
    ${GEM_BUILT_FILE} -- ${GEM_INSTALL_FLAGS}

  # create symlink from the gems bin directory to /usr/bin
  for i in ${D}/${libdir}/ruby/gems/${RUBY_GEM_VERSION}/bin/*; do
    if [ -e "$i" ]; then
      if [ ! -d ${D}/${bindir} ]; then mkdir -p ${D}/${bindir}; fi
      b=`basename $i`
      ln -sf ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/bin/$b ${D}/${bindir}/$b
    fi
  done
}

EXPORT_FUNCTIONS do_patch do_compile do_install

PACKAGES = "${PN}-dbg ${PN} ${PN}-doc ${PN}-dev"

FILES_${PN}-dbg += " \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/*/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/extensions/*/*/*/*/*/.debug \
        "

FILES_${PN} += " \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/cache \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/bin \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/specifications \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/build_info \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/extensions/*/*/*/*.so \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/extensions \
        "

FILES_${PN}-doc += " \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/doc \
        "
