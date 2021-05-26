#!/bin/bash

if [ $# -ne 1 ];then
	echo "Please provide a bug id from syzbot dashboard"
	exit 0
fi

if [ -d "$1" ];then
	echo "The kernel bug $1 already exists"
	exit 0
fi

mkdir -p $1
pushd $1
cp ../Scripts/get_bug_info.py .
# If the second argument get_bug_info.py is 1, only export crashes with reproducers;
# Otherwise, only export crashes without reproducers.
python3 get_bug_info.py $1 1
for dir in `ls`; do cp ../Scripts/deploy_env.sh $dir; done
rm -rf get_bug_info.py
popd
