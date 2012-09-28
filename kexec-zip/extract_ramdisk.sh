#!/tmp/busybox sh

cd /tmp
export PATH=/tmp:/:/sbin:/system/xbin:/system/bin:$PATH

bml_over_mtd dump boot 72 reservoir 4012 boot.img
eval $(busybox grep -m 1 -A 1 BOOT_IMAGE_OFFSETS boot.img | busybox tail -n 1)
busybox dd if=boot.img skip=$boot_offset count=$boot_len of=boot.cpio.gz
