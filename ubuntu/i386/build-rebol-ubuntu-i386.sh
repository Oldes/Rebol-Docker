#!/bin/sh

# this script is supposed to be run from rebol-dev container!!!

export ARCH=x86
export LIBC=glibc_2.27

cd /rebol/Builder/
git pull
/bin/rebol siskin.r3 rebol rebol3-base-linux-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-base-linux-$ARCH /out/rebol3-base-linux-$ARCH-$LIBC
chmod a+x /out/rebol3-base-linux-$ARCH-$LIBC

/bin/rebol siskin.r3 rebol rebol3-core-linux-$ARCH
chmod a+x /out/rebol3-core-linux-$ARCH-$LIBC
mv ./tree/rebol/Rebol/build/rebol3-core-linux-$ARCH /out/rebol3-core-linux-$ARCH-$LIBC

/bin/rebol siskin.r3 rebol rebol3-bulk-linux-$ARCH
mv ./tree/rebol/Rebol/build/rebol3-bulk-linux-$ARCH /out/rebol3-bulk-linux-$ARCH-$LIBC
chmod a+x /out/rebol3-bulk-linux-$ARCH-$LIBC

/out/rebol3-base-linux-$ARCH-$LIBC -v
/out/rebol3-core-linux-$ARCH-$LIBC -v
/out/rebol3-bulk-linux-$ARCH-$LIBC -v
gzip -9 /out/rebol3-base-linux-$ARCH-$LIBC
gzip -9 /out/rebol3-core-linux-$ARCH-$LIBC
gzip -9 /out/rebol3-bulk-linux-$ARCH-$LIBC
