#!/bin/bash
set -e -x
# Install Libraries
apt-get update
apt-get install -y --no-install-recommends libgl1-mesa-glx libglib2.0-0
rm -rf /var/lib/apt/lists/*
