#!/bin/bash
set -e -x
# install toolset
apt-get update
apt-get install -qq --no-install-recommends ca-certificates curl software-properties-common locales
rm -rf /var/lib/apt/lists/*
# Set locale
locale-gen en_US.UTF-8
