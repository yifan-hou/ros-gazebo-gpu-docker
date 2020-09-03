#!/usr/bin/env bash

set -euo pipefail

# To make sure the build context isn't cluttered,
# we just cd into the directory of this script.
cd "$(dirname "$0")"

docker build -t yifan/ros-gpu:melodic-nvidia -f melodic.Dockerfile .
