#!/bin/bash
set -e -x
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get install -qq --no-install-recommends python3.9 python3.9-distutils
apt-get purge -y --auto-remove python3.6
rm -rf /var/lib/apt/lists/*
# set python3.9 as default python
curl https://bootstrap.pypa.io/get-pip.py -o /dev/stdout | python3.9
update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3 1
update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
