#!/bin/sh

wget https://storage.googleapis.com/syzkaller/stretch.img
wget https://storage.googleapis.com/syzkaller/stretch.img.key -O stretch.id_rsa
chmod 0600 stretch.id_rsa

#wget https://storage.googleapis.com/syzkaller/wheezy.img
#wget https://storage.googleapis.com/syzkaller/wheezy.img.key
#chmod 0600 wheezy.img.key
