#/usr/bin/perl
#
# Meta-Diaspberry
#
# Copyright (C) 2016 Lukas Matt <lukas@zauberstuhl.de>,
# Matthias Neutzner <matthias.neutzner@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
use strict;

my $skip_groups = {
  'test' => 1,
  'development' => 1,
  'mysql' => 1
};

my $tmp_folder = "/tmp";
my $reciepe_folder = "recipes-rubygems";
my $diaspora_dep_file = "recipes-core/diaspora/dependencies.inc";

my $dummy_gem = <<EOT;
SUMMARY = "{GEM} - A ruby gem"
DESCRIPTION = "\${SUMMARY}"
GEM_NAME = "{GEM}"
HOMEPAGE = "http://rubygems.org/gems/{GEM}"
SECTION = "devel/ruby"
LICENSE = "{LIC}"
LIC_FILES_CHKSUM = "file://{LICFILE};md5={LICMD5}"
{GEM_SRC}

SRC_URI[md5sum] = "{MD5}"
SRC_URI[sha256sum] = "{SHA256}"

PR = "r0"

inherit rubygems
EOT

my $group_skip = 0;
open (FH, '<', $ARGV[0]) or die $!;
open (DDH, '>', $diaspora_dep_file) or die $!;
print DDH "DEPENDS = \" \\\n";
while (<FH>) {
  my $gemfile_line = $_;
  my ($gem, $version, $source) = (undef, undef, undef);

  # skip all unnecessary groups
  if ($gemfile_line =~ /^group\s+\:(\w+)/
  && defined $skip_groups->{$1}) {
    $group_skip = 1;
  }
  if ($group_skip) {
    if ($gemfile_line =~ /^end/) {
      $group_skip = 0;
    }
    next;
  }

  # with version number
  if ($gemfile_line =~ /^\s*gem\s+"(.+?)",\s+"([0-9\.\w]+?)"/ig) {
    ($gem, $version) = ($1, $2);
  }
  # without version number
  if ($gemfile_line =~ /^\s*gem\s+"(.+?)"/ig) {
    ($gem, $version) = ($1, undef);
  }
  # with different source
  if ($gemfile_line =~ /source:\s*"([^"]+?)"/ig) {
    $source = $1;
  } elsif ($gem =~ /^rails-assets-/) {
    # incase it is a group
    $source = "https://rails-assets.org";
  }

  next unless defined $gem;

  print "[+] working on $gem $version\n";

  my $gem_file_content = $dummy_gem;
  $gem_file_content =~ s/\{GEM\}/$gem/g;
  if (defined $source) {
    $gem_file_content =~ s/\{GEM_SRC\}/GEM_SRC = "$source\/gems"/g;
  } else {
    $gem_file_content =~ s/\{GEM_SRC\}//d;
  }

  my $version_opts = "-v $version";
  unless (defined $version) {
    $version = "*";
    $version_opts = "";
  }
  if (defined $source) {
    $version_opts .= " -s $source";
  }

  # download only if not available locally
  unless (-d "$tmp_folder/$gem-$version") {
    system("cd $tmp_folder && \
      gem fetch $gem $version_opts && \
      gem unpack $gem-$version.gem");
  }

  if ($version eq "*") {
    $version = `cd $tmp_folder/$gem-[0-9]* && pwd` or die $!;
    chomp($version);
    $version =~ s/^.*-(\d+\.[\d\.]+)$/$1/g;
    print "   New version is $version\n";
  }

  my $license_file = `find $tmp_folder/$gem-$version |grep -Ei 'license|copying' |head -n1` or warn $!;
  chomp($license_file);
  if ($license_file eq "") {
    $gem_file_content =~ s/\{LIC\}/CLOSED/g;
    $gem_file_content =~ s/LIC_FILES_CHKSUM = "(.+?)"//g;
  } else {
    $gem_file_content =~ s/\{LIC\}/Unknown/g;

    my $licmd5 = `md5sum $license_file |cut -d' ' -f1` or die $!;
    chomp($licmd5);

    $license_file =~ s/$tmp_folder\/$gem-$version\///;
    $gem_file_content =~ s/\{LICFILE\}/$license_file/g;
    $gem_file_content =~ s/\{LICMD5\}/$licmd5/g;
  }

  my $md5 = `md5sum $tmp_folder/$gem-$version.gem |cut -d' ' -f1` or die $!;
  chomp($md5);
  my $sha256 = `sha256sum $tmp_folder/$gem-$version.gem |cut -d' ' -f1` or die $!;
  chomp($sha256);

  $gem_file_content =~ s/\{MD5\}/$md5/g;
  $gem_file_content =~ s/\{SHA256\}/$sha256/g;

  # bitbake only allows underscores
  # for separating the reciepe name
  # from the version number
  $gem =~ s/_/-/g;

  my $reciepe_file = "$reciepe_folder/gem-$gem/gem-$gem\_$version.bb";
  unless (-e $reciepe_file) {
    system("mkdir -p $reciepe_folder/gem-$gem");
    open(GH, '>', $reciepe_file) or die $!;
    print GH $gem_file_content;
    close GH;
  } else {
    print "    $gem-$version already exists! Skipping..\n";
  }

  print DDH "  gem-$gem (= $version) \\\n";
}
print DDH "  \"\n";
close DDH;
close FH;
