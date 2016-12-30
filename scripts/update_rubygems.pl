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
use Data::Dumper;

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
{GEM_SRC_TLD}

SRC_URI[md5sum] = "{MD5}"
SRC_URI[sha256sum] = "{SHA256}"

PR = "r0"

inherit rubygems
EOT


my $specs = 0;
my $lock = {};
open (FH, '<', $ARGV[0]) or die $!;
while(<FH>) {
  my $line = $_;
  if ($line =~ /^\s+specs:/) {
    $specs = 1;
  }
  if ($specs && $line =~ /^\w+/) {
    $specs = 0;
  }

  if ($specs) {
    #      rails-dom-testing (~> 1.0, >= 1.0.5)
    $line =~ /^\s+([^\s]+?)\s\((.+?)\)$/;
    my ($name, $version) = ($1, $2);
    push @{$lock->{$name}}, "$version";
  }
}
close FH;

open (DDH, '>', $diaspora_dep_file) or die $!;
print DDH "RDEPENDS_\${PN} = \" \\\n";

for my $gem (keys %$lock) {
  next if $gem =~ /^\s*$/;

  print "[+] working on $gem ";
  my $version_string = join(', ', @{$lock->{$gem}});
  print "with '$version_string'\n";

  my $source = undef;
  if ($gem =~ /^rails-assets-/) {
    $source = "http://rails-assets.org";
  }

  my $version_opts = "-v '$version_string'";
  my $gem_file_content = $dummy_gem;
  $gem_file_content =~ s/\{GEM\}/$gem/g;
  if (defined $source) {
    $version_opts .= " -s $source";
    $gem_file_content =~ s/\{GEM_SRC_TLD\}/GEM_SRC_TLD = "$source"/g;
  } else {
    $gem_file_content =~ s/\{GEM_SRC_TLD\}//d;
  }

  my $fetch_result = `cd $tmp_folder && gem fetch $gem $version_opts`;
  # e.g Fetching: sprockets-2.12.3.gem
  my $version = undef;
  if ($fetch_result =~ /Downloaded\s$gem\-(.*?)$/g) {
    $version = $1;
  } else { die "No version found: $!"; }
  system("cd $tmp_folder && gem unpack $gem-$version.gem");

  my $license_file = `find $tmp_folder/$gem-$version |grep -Ei 'license|copying' |head -n1`
    or warn "No license file found";
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

  print DDH "  gem-$gem (= $version) \\\n";

  my $reciepe_file = "$reciepe_folder/gem-$gem/gem-$gem\_$version.bb";
  unless (-e $reciepe_file) {
    system("mkdir -p $reciepe_folder/gem-$gem");
    open(GH, '>', $reciepe_file) or die $!;
    print GH $gem_file_content;
    close GH;
  }
}

print DDH "  \"\n";
close DDH;
