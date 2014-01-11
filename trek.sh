#!/bin/bash
source build/envsetup.sh
make installclean && rm -rf out/target/product/jfltevzw/*md5sum
# jfltevzw
brunch jfltevzw -j21
