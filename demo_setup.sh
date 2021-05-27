#!/bin/bash

set -eux

# install prerequisite packages on Ubuntu system
# install_prerequisites
sudo apt update
sudo apt install python3-pip
pip install bs4
sudo apt install unzip flex bison libelf-dev libssl-dev build-essential libncurses5-dev

export PATH=$PATH:/usr/local/go/bin

pushd Kernel_repos/
./clone_repos.sh
popd

pushd Go_pkg/
./install_go.sh
popd

pushd Images
./download_image.sh
popd

./deploy_env.sh ddc83e209f712ce63078e146f7c0fe63e1edbc2f
cd ddc83e209f712ce63078e146f7c0fe63e1edbc2f/1
./deploy_env.sh
