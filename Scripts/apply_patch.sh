#!/bin/bash

set -ex

source repro.cfg

if [ $# -ne 1 ];then
    echo "No argument provided or incorrect argument number"
    exit 0
fi

KERNEL_REPO="$HOME/Repos/${kern_repo}"
TEMP_FOLD="$PWD/backup"

#1. get kernel source code
pushd $KERNEL_REPO
git format-patch -1 -o $TEMP_FOLD $1
popd
cp -rf linux linux-patched
pushd linux-patched
patch -p1 < $TEMP_FOLD/0001-*.patch
make -j32
popd
