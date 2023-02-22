#!/bin/sh

# this script is supposed to be run from rebol-dev container!!!

export ARCH=mips64le

cd /rebol/Builder/
git pull
/bin/rebol siskin.r3 rebol rebol3-base-linux-$ARCH
/bin/rebol siskin.r3 rebol rebol3-core-linux-$ARCH
/bin/rebol siskin.r3 rebol rebol3-bulk-linux-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-base-linux-$ARCH /out/rebol3-base-linux-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-core-linux-$ARCH /out/rebol3-core-linux-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-bulk-linux-$ARCH /out/rebol3-bulk-linux-$ARCH
chmod a+x /out/rebol3-base-linux-$ARCH
chmod a+x /out/rebol3-core-linux-$ARCH
chmod a+x /out/rebol3-bulk-linux-$ARCH
/out/rebol3-base-linux-$ARCH -v
/out/rebol3-core-linux-$ARCH -v
/out/rebol3-bulk-linux-$ARCH -v
gzip -9 /out/rebol3-base-linux-$ARCH
gzip -9 /out/rebol3-core-linux-$ARCH
gzip -9 /out/rebol3-bulk-linux-$ARCH
