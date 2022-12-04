#!/bin/bash

require_file() {
    if [ ! -f "$1" ]; then
        echo "$2 does not exist. Trying to dowload it"
        wget $3 -O $1
        error_check
        echo "$2 successfuly downloaded."
    else
        echo "$2 is present."
    fi
}

error_check() {
if [ $? -ne 0 ]; then
    echo "Something went wrong. Exiting."
    exit -1
fi
}

PLATFORM=$1
DESTINATION=$2

if [ -z "$PLATFORM" ]
then
      echo "Platform codename is empty!"
      exit -1
fi

if [ -z "$DESTINATION" ]
then
      echo "Destination is empty!"
      exit -1
fi

echo "Deploying system for $PLATFORM to $DESTINATION"

ROOTFS=./workdir/rootfs.tar.gz
ZIMAGE=./workdir/$PLATFORM-zImage
MODULES=./workdir/$PLATFORM-modules.tar.gz
HARET=./workdir/haret-w.exe
STARTUP=./workdir/startup.txt
if [[ "${DESTINATION}" == *"mmcblk"* ]]; then
  BOOT=${DESTINATION}p1
  LINUX=${DESTINATION}p2
else
  BOOT=${DESTINATION}1
  LINUX=${DESTINATION}2
fi

require_file $ROOTFS "rootfs" "https://github.com/AlexCatze/pda-rootfs/releases/latest/download/rootfs.tar.gz"
require_file $ZIMAGE "zImage" "https://github.com/AlexCatze/linux/releases/latest/download/${PLATFORM}-zImage"
require_file $MODULES "modules" "https://github.com/AlexCatze/linux/releases/latest/download/${PLATFORM}-modules.tar.gz"
require_file $HARET "haret" "https://github.com/AlexCatze/pda-rootfs/raw/main/shared/haret-w.exe"
require_file $STARTUP "startup" "https://raw.githubusercontent.com/AlexCatze/pda-rootfs/main/${PLATFORM}/startup.txt"

if [ ! -b "$BOOT" ]; then
    echo "boot partition does not exist."
    exit -1
fi
if [ ! -b "$LINUX" ]; then
    echo "linux partition does not exist."
    exit -1
fi

echo "Trying to unmount partitions, just safety tick if they are mount"

umount $BOOT
umount $LINUX

echo "All files present. Going to deploy."

mkdir ./mount
echo "Formating boot"
mkfs -t vfat -n BOOT $BOOT
error_check
echo "Mounting boot"
mount $BOOT ./mount
error_check
echo "Copying boot files"
cp $HARET ./mount
error_check
cp $STARTUP ./mount
error_check
cp $ZIMAGE ./mount
error_check
echo "Unmounting boot"
umount ./mount
error_check

echo "Formating linux"
yes | mkfs -t ext3 -L LINUX $LINUX
error_check
echo "Mounting linux"
mount $LINUX ./mount
error_check
echo "Extracting rootfs"
tar -C ./mount -xvf $ROOTFS --strip-components=2
error_check
echo "Extracting modules"
tar -C ./mount -xvf $MODULES --strip-components=2
error_check
echo "Unmounting linux"
umount ./mount
error_check
echo "Cleaning up"
rm -r ./mount
error_check

echo "Done!"
