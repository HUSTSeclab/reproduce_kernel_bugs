#!/bin/bash

export PATH=$PATH:/usr/local/go/bin

sudo rm -rf /usr/local/go/ go1.14.2.linux-amd64.tar.gz
wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
sudo tar -C /usr/local/ -xzf go1.14.2.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
go env
