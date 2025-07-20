#!/bin/bash
set -e
 
SRC_LIB="../native/nursorcore/src/macos/libncore.dylib"
DST_DIR="./Runner"
cp -f "$SRC_LIB" "$DST_DIR"
echo "Copied $SRC_LIB to $DST_DIR"