# Rebol-Docker

[![Alpine](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine.yml/badge.svg)](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine.yml)
[![Alpine-dev](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine-dev.yml/badge.svg)](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine-dev.yml)

This repository includes various Rebol-related Docker files, along with a simple Rebol/Docker module. The module is designed to help automate common Docker tasks directly from Rebol, making it easier to integrate Docker workflows into your scripts.

## Bootstrap Rebol for Red Hat 8 linux distro

Following Rebol script is an example, how to build all main Rebol products for RedHat8 Linux distro (libc2.28) using a boostrap Rebol build.

```rebol
docker: import %docker.reb

;; Validate if Docker is available...
unless docker/version [
	print "Docker not installed!"
	exit
]

;; Prepare a directory for new build results... 
make-dir %out/

;; Run bootstrap build script in a Red Hat 8 image...
docker/run/console [
    name:  "rebol-bootstrap-ubi8"
    image: "docker.io/oldes/ubi8-gcc-x64"
    flags: [--rm]
    volumes: [
       ; %/c/Dev/Builder/ %/rebol/Builder/
       ; %/c/Dev/Builder/tree/rebol/Rebol-bootstrap/ %/rebol/Rebol-bootstrap/
       ; %/c/Dev/Builder/tree/rebol/Rebol-Docker/scripts/ %/rebol/scripts/
       %out/ %/temp/out/
    ]
    command: %%{
#!/bin/sh
uname -a                # Show kernel and system information for build logs

# Determine glibc version from ldd output; falls back silently if ldd is missing
LIBC=$(ldd --version 2>/dev/null | head -n1 | awk '{print $NF}')  # Extract version number (e.g., 2.35)
LIBC_MAJOR=$(echo "$LIBC" | cut -d. -f1)                          # Major version (e.g., 2)
LIBC_MINOR=$(echo "$LIBC" | cut -d. -f2)                          # Minor version (e.g., 35)
LIBC=$(echo "libc${LIBC_MAJOR}_${LIBC_MINOR}")                    # Normalize to label like libc2_35

cd /temp/                                                         # Work in a temporary build directory

# Clone only the bootstrap branch to minimize fetch size
git clone --branch bootstrap --single-branch https://github.com/Siskin-framework/Rebol.git
cd Rebol/make                                                     # Enter makefiles directory for bootstrap
make -f rebol-linux-bootstrap-64bit.mk                            # Build 64-bit bootstrap binary
mv ./rebol-linux-bootstrap-64bit /usr/local/bin/rebol-stage0      # Install bootstrap interpreter as rebol-stage0

# Fetch the Builder tool shallowly to speed up CI
git clone https://github.com/Siskin-Framework/Builder --depth 1
cd Builder

# Use stage-0 to build three flavors of the interpreter
rebol-stage0 siskin.r3 rebol rebol3-base-linux-x64                # Build base variant
rebol-stage0 siskin.r3 rebol rebol3-core-linux-x64                # Build core variant
rebol-stage0 siskin.r3 rebol rebol3-bulk-linux-x64                # Build bulk variant

# Print versions of the newly built binaries for verification
tree/rebol/Rebol/build/rebol3-base-linux-x64 -v
tree/rebol/Rebol/build/rebol3-core-linux-x64 -v
tree/rebol/Rebol/build/rebol3-bulk-linux-x64 -v

# Rename artifacts with architecture and libc tag to document runtime compatibility
mv tree/rebol/Rebol/build/rebol3-base-linux-x64 /temp/out/rebol3-base-linux-x64_${LIBC}
mv tree/rebol/Rebol/build/rebol3-core-linux-x64 /temp/out/rebol3-core-linux-x64_${LIBC}
mv tree/rebol/Rebol/build/rebol3-bulk-linux-x64 /temp/out/rebol3-bulk-linux-x64_${LIBC}

ls -la /temp/out/     # List final artifacts for CI logs
    }%%
]

