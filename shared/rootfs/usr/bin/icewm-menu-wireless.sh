#!/bin/bash


file_count=$(find /lib/modules -name hx4700_acx.ko | wc -l)
if [[ $file_count -gt 0 ]]; then
  if lsmod | grep "hx4700_acx" &> /dev/null ; then
    echo "prog \"Disable WI-FI\" /usr/share/icons/Adwaita/32x32/devices/network-wired.png bash -c \"rmmod hx4700_acx; rmmod acx-mac80211\"\n"
  else
    echo "prog \"Enable WI-FI\" /usr/share/icons/Adwaita/32x32/status/network-wired-disconnected.png bash -c \"modprobe acx-mac80211; modprobe hx4700_acx\"\n"
  fi
fi
