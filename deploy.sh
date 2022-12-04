#!/bin/bash
PLATFORM=$1
DESTINATION=$2

if [ -z "$PLATFORM" ]
then
      echo "Platform is empty!"
      exit
fi

if [ -z "$DESTINATION" ]
then
      echo "Destination is empty!"
      exit
fi

echo "Deploying system for $PLATFORM to $DESTINATION"

ROOTFS=./workdir/rootfs.tar.gz
ZIMAGE=./workdir/$PLATFORM-zImage
MODULES=./workdir/$PLATFORM-modules.tar.gz
HARET=./shared/haret-w.exe
STARTUP=./$PLATFORM/startup.txt
BOOT=${DESTINATION}p1
LINUX=${DESTINATION}p2

if [ ! -f "$ROOTFS" ]; then
    echo "rootfs does not exist."
    exit
fi
if [ ! -f "$ZIMAGE" ]; then
    echo "zImage does not exist."
    exit
fi
if [ ! -f "$MODULES" ]; then
    echo "modules does not exist."
    exit
fi
if [ ! -f "$HARET" ]; then
    echo "haret does not exist."
    exit
fi
if [ ! -f "$STARTUP" ]; then
    echo "startup does not exist."
    exit
fi

if [ ! -b "$BOOT" ]; then
    echo "boot partition does not exist."
    exit
fi
if [ ! -b "$LINUX" ]; then
    echo "linux partition does not exist."
    exit
fi

#TODO:check if partition mount

echo "All files present. Going to deploy."

mkdir ./mount
echo "Formating boot"
mkfs -t vfat -n BOOT $BOOT
echo "Mounting boot"
mount $BOOT ./mount
echo "Copying boot files"
cp $HARET ./mount
cp $STARTUP ./mount
cp $ZIMAGE ./mount
echo "Unmounting boot"
umount ./mount

echo "Formating linux"
yes | mkfs -t ext3 -L LINUX $LINUX
echo "Mounting linux"
mount $LINUX ./mount
echo "Extracting rootfs"
tar -C ./mount -xvf $ROOTFS --strip-components=2 #tar -C ./mount -xvf $ROOTFS rootfs
echo "Extracting modules"
tar -C ./mount -xvf $MODULES --strip-components=2 #tar -C ./mount -xvf $MODULES modules
echo "Unmounting linux"
umount ./mount
echo "Cleaning up"
rm -r ./mount

echo "Done!"
