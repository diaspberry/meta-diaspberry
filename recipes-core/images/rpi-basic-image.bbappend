# nodejs is required as well but not supported for qemuarm

IMAGE_INSTALL += " \
  ruby imagemagick redis postgresql git curl \
  cmake libxml2 libxslt ghostscript \
  "
