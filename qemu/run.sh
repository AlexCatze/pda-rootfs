qemu-system-arm -m 256 -M versatilepb -kernel ../workdir/qemu-zImage -append "root=/dev/sda2 rw console=ttyAMA0 console=tty0" -drive file=/dev/mmcblk0,if=scsi,format=raw
