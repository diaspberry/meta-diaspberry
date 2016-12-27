Updating rubygems
-----------------

Make sure you have following commandline tools:

    which gem md5sum sha256sum

then run the helper script from the working directory:

    cd meta-diaspberry
    perl scripts/update_rubygems.pl path/to/Gemfile
