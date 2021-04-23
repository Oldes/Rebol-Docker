#!/bin/sh

# this script is supposed to be run from rebol-dev container

cd /rebol/Builder/
/bin/rebol siskin.r3 rebol 1
/bin/rebol siskin.r3 rebol 2
/bin/rebol siskin.r3 rebol 3
mv ./tree/rebol/Rebol/build/rebol3-base-x64-libc-gcc /out/rebol3-base-x64-musl
mv ./tree/rebol/Rebol/build/rebol3-core-x64-libc-gcc /out/rebol3-core-x64-musl
mv ./tree/rebol/Rebol/build/rebol3-bulk-x64-libc-gcc /out/rebol3-bulk-x64-musl
chmod a+x /out/rebol3-base-x64-musl
chmod a+x /out/rebol3-core-x64-musl
chmod a+x /out/rebol3-bulk-x64-musl
