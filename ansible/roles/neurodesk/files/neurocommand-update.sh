#!/bin/sh -e
cd /neurocommand
git fetch
git pull
./build.sh
