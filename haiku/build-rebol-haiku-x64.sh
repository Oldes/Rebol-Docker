#!/bin/sh

# this script is supposed to be run from rebol-dev container!!!

export ARCH=x64

cd /rebol/Builder/
git pull
/bin/rebol siskin.r3 rebol rebol3-base-haiku-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-base-haiku-$ARCH /out/rebol3-base-haiku-$ARCH

/bin/rebol siskin.r3 rebol rebol3-core-haiku-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-core-haiku-$ARCH /out/rebol3-core-haiku-$ARCH

/bin/rebol siskin.r3 rebol rebol3-bulk-haiku-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-bulk-haiku-$ARCH /out/rebol3-bulk-haiku-$ARCH

chmod a+x /out/rebol3-base-haiku-$ARCH
chmod a+x /out/rebol3-core-haiku-$ARCH
chmod a+x /out/rebol3-bulk-haiku-$ARCH
/out/rebol3-base-haiku-$ARCH -v
/out/rebol3-core-haiku-$ARCH -v
/out/rebol3-bulk-haiku-$ARCH -v
gzip -9 /out/rebol3-base-haiku-$ARCH
gzip -9 /out/rebol3-core-haiku-$ARCH
gzip -9 /out/rebol3-bulk-haiku-$ARCH
