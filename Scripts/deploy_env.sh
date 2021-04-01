#!/bin/bash

set -ex

source repro.cfg

BASE_DIR="${PWD}/../.."
KERNEL_REPO="${BASE_DIR}/Kernel_repos/${kern_repo}"
TEMP_FILE="/tmp/kernel_${bug_id}.zip"

#1. prepare README
echo "https://syzkaller.appspot.com/bug?id=${bug_id}" > README 

#2. get kernel source code
pushd $KERNEL_REPO
git archive --format zip --output $TEMP_FILE $commit_id
popd
mkdir -p linux backup
unzip $TEMP_FILE -d linux/
# backup linux source code in case you will modify it
mv $TEMP_FILE backup

#3. compile kernel source code
wget $config_url -O config
pushd linux
cp ../config .config
make -j8
# disable make cscope by default 
make cscope -j8
popd

#4. get log report and poc
wget $log_url -O log
wget $report_url -O report
if [ "$syz_url" != "" ]; then wget $syz_url -O syz; fi
if [ "$poc_url" != "" ]; then wget $poc_url -O poc.c; fi

#5. copy stretch image and ssh key
mkdir -p image
cp -r $BASE_DIR/Images/wheezy.* image &

#TODO: only build syzkaller if syz_url is non-empty and poc_url is empty
#6. get certain version of syzkaller
mkdir -p gopath
# use GOROOT of the default go1.12 in the system
export GOPATH=$PWD/gopath
#go get -u -d github.com/google/syzkaller/...
go get -u -d github.com/google/syzkaller/prog
pushd $GOPATH/src/github.com/google/syzkaller/
git checkout $syzkaller_id
make -j8
popd

#7. copy useful bash script here
cp $BASE_DIR/Scripts/*vm .

#8. copy syzkaller binary
mkdir -p bin
find . -name "syz-execprog" | grep "bin" | xargs -I {}  cp {} $PWD/bin/syz-execprog
find . -name "syz-executor" | grep "bin" | xargs -I {}  cp {} $PWD/bin/syz-executor
