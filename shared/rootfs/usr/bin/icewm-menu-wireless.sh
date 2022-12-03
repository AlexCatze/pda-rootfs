#!/bin/bash
if lsmod | grep "hx4700_acx" &> /dev/null ; then
  echo "prog \"Disable WI-FI\" /usr/share/icons/Adwaita/32x32/devices/network-wired.png bash -c \"rmmod hx4700_acx; rmmod acx-mac80211\"\n"
else
  echo "prog \"Enable WI-FI\" /usr/share/icons/Adwaita/32x32/status/network-wired-disconnected.png bash -c \"insmod hx4700_acx; insmod acx-mac80211\"\n"
fi
