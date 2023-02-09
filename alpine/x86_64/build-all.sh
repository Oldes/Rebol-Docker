#!/bin/sh

# this script is supposed to be run from rebol-dev container

cd /rebol/Builder/
git pull
/bin/rebol siskin.r3 rebol --list
/bin/rebol siskin.r3 rebol rebol3-base-linux-x64
/bin/rebol siskin.r3 rebol rebol3-core-linux-x64
/bin/rebol siskin.r3 rebol rebol3-bulk-linux-x64
mv ./tree/rebol/Rebol/build/rebol3-base-linux-x64 /out/rebol3-base-linux-x64-musl
mv ./tree/rebol/Rebol/build/rebol3-core-linux-x64 /out/rebol3-core-linux-x64-musl
mv ./tree/rebol/Rebol/build/rebol3-bulk-linux-x64 /out/rebol3-bulk-linux-x64-musl
chmod a+x /out/rebol3-base-linux-x64-musl
chmod a+x /out/rebol3-core-linux-x64-musl
chmod a+x /out/rebol3-bulk-linux-x64-musl
