#!/bin/bash

set -ex

source repro.cfg

BASE_DIR="../.."
KERNEL_REPO="$BASE_DIR/Kernel_repos/${kern_repo}"
BACKUP="$PWD/backup"
TEMP_FILE="/tmp/kernel_${bug_id}.zip"
PATCH_FILE="/tmp/$1.patch"

#1. prepare README
echo "https://syzkaller.appspot.com/bug?id=${bug_id}" > README 

#2. get kernel source code
pushd $KERNEL_REPO
git archive --format zip --output $TEMP_FILE $commit_id
popd
mkdir -p linux backup
unzip $TEMP_FILE -d linux/
mv $TEMP_FILE backup

#3. compile kernel source code
wget $config_url -O config
pushd linux
cp ../config .config
make -j32
make cscope -j32
popd

#3.1 set up and compile patched kernel source code
pushd $KERNEL_REPO
git format-patch -1 -o $BACKUP $fix_commit
popd
cp -rf linux linux-patched
pushd linux-patched
patch -p1 < $BACKUP/0001-*.patch
make -j32
popd

#4. get log report and poc
wget $log_url -O log
wget $report_url -O report
if [ "$syz_url" != "" ];then wget $syz_url -O syz;fi
if [ "$poc_url" != "" ];then wget $poc_url -O poc.c;fi

#5. copy stretch image and ssh key
mkdir -p image
cp -r $BASE_DIR/Images/* image &

#6. get certain version of syzkaller
if [ "$poc_url" == "" ]; then
	mkdir -p gopath
	# use GOROOT of the default go1.12 in the system
	export GOPATH=$PWD/gopath

	#go get -u -d github.com/google/syzkaller/...
	go get -u -d github.com/google/syzkaller/prog
	pushd $GOPATH/src/github.com/google/syzkaller/
	git checkout $syzkaller_id
	make -j8
	popd
fi

#7. copy useful bash script here
cp $BASE_DIR/Scripts/*vm .
rm scpfromvm

#8. copy syzkaller binary
if [ "$poc_url" == "" ]; then
	mkdir -p bin
	find . -name "syz-execprog" | grep "bin" | xargs -I {}  cp {} $PWD/bin/syz-execprog
	find . -name "syz-executor" | grep "bin" | xargs -I {}  cp {} $PWD/bin/syz-executor
	find . -name "syz-prog2c" | grep "bin" | xargs -I {}  cp {} $PWD/bin/syz-prog2c
fi
