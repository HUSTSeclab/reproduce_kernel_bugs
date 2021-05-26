#!/bin/bash

BASE_DIR="${PWD}/.."
KERNEL_REPO="${BASE_DIR}/Kernel_repos/linux"
TEMP_FILE="/tmp/kernel.zip"

if [ $# -eq 0 ]
then
	echo "No arguments is provided, please provide one commit id"
	exit 0
fi

pushd $KERNEL_REPO
git archive --format zip --output $TEMP_FILE $1
popd

unzip $TEMP_FILE -d linux_$1/

#pushd linux_$1
#make cscope
#popd
