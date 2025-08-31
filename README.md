# Rebol-Docker

[![Alpine](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine.yml/badge.svg)](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine.yml)
[![Alpine-dev](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine-dev.yml/badge.svg)](https://github.com/Oldes/Rebol-Docker/actions/workflows/alpine-dev.yml)

This repository includes various Rebol-related Docker files, along with a simple [Rebol/Docker module](docker.reb). The module is designed to help automate common Docker tasks directly from Rebol, making it easier to integrate Docker workflows into your scripts.

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
    flags: [
        --platform "linux/amd64"  ;; just in case when host isn't x64 
        --rm                      ;; remove container after use
    ]
    volumes: [
        ;- Map local host out directory to /temp/out in the container
        %out/ %/temp/out/
        ;- Instead of pulling sources from Git, modified script could use local files
        ;; %/c/Dev/Builder/ %/rebol/Builder/
        ;; %/c/Dev/Builder/tree/rebol/Rebol-bootstrap/ %/rebol/Rebol-bootstrap/
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
```
If the above script runs successfully, three new Linux binaries will be created in the `out/` folder.
<img width="1106" height="768" alt="image" src="https://github.com/user-attachments/assets/bc907994-a5e3-4790-b37e-ab6beaf6c4e3" />
These binaries can then be used in a subsequent run, for example:
```rebol
docker/run/console [
    name:  "test-rebol-ubi8"
    image: "docker.io/oldes/ubi8-gcc-x64"
    flags: [
        --platform "linux/amd64"  ;; just in case when host isn't x64 
        --rm                      ;; remove container after use
    ]
    volumes: [
    	;; map Rebol/Bulk bimnary as /bin/rebol3
        %out/rebol3-bulk-linux-x64_libc2_28 %/bin/rebol3
    ]
    ;; try to use it:
    command: {rebol3 --do "probe system/build"}
]
```
With result like:
```rebol
make object! [
    os: 'rhel
    os-version: "8.10"
    abi: 'elf
    sys: 'linux
    arch: 'x64
    libc: 'none
    vendor: 'pc
    target: 'x64-pc-linux-elf
    compiler: 'gcc
    date: 29-Aug-2025/16:21
    git: #{75B9807E6F6E6E2AC3B2FB025EBE0F8A9A6D0FFA}
]
```
