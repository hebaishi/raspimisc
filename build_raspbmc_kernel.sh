#!/bin/bash
export CCPREFIX="/home/husam/work/raspi_cross/tools-master/arm-bcm2708/arm-bcm2708hardfp-linux-gnueabi/bin/arm-bcm2708hardfp-linux-gnueabi-"
export CFLAGS="-pipe -Ofast -mcpu=arm1176jzf-s -mtune=arm1176jzf-s -mfloat-abi=hard -mfpu=vfp -fomit-frame-pointer -fexcess-precision=fast -flto -fuse-linker-plugin"
export CPPFLAGS="-pipe -Ofast -mcpu=arm1176jzf-s -mtune=arm1176jzf-s -mfloat-abi=hard -mfpu=vfp -fomit-frame-pointer -fexcess-precision=fast -flto -fuse-linker-plugin"
if [ $# -eq 1 ]
then
cores=-j"$1"
else
cores="-j1"
fi
#wget https://github.com/raspberrypi/linux/archive/rpi-3.10.y.tar.gz
tar -xzf rpi-3.10.y.tar.gz
#rm rpi-3.10.y.tar.gz
LINUXDIR="linux-rpi-3.10.y"
export RAMFSDIR=$(pwd)/${LINUXDIR}/initramfs
cd $LINUXDIR
wget http://svn.stmlabs.com/svn/raspbmc/patches/kernel-3.10.patch
patch -p1 -l < kernel-3.10.patch
wget http://svn.stmlabs.com/svn/raspbmc/patches/kernel-hardfp-3.10.patch
patch -p1 < kernel-hardfp-3.10.patch
BFQPATCHES="0001-block-cgroups-kconfig-build-bits-for-BFQ-v6r2-3.10.8.patch
0002-block-introduce-the-BFQ-v6r2-I-O-sched-for-3.10.8.patch
0003-block-bfq-add-Early-Queue-Merge-EQM-to-BFQ-v6r2-for-.patch
"
for patch in $BFQPATCHES
do
wget http://svn.stmlabs.com/svn/raspbmc/patches/$patch
patch -p1 < $patch
done
wget http://svn.stmlabs.com/svn/raspbmc/patches/ipconfig.c -O net/ipv4/config.c
wget http://svn.stmlabs.com/svn/raspbmc/patches/e4000.c -O drivers/media/tuners/e4000.c
lang=C svn export svn://dev.stmlabs.com/raspbmc/patches/rtl8188eu drivers/staging/rtl8188eu
wget http://svn.stmlabs.com/svn/raspbmc/release/kernel/config-3.10 -O .config
wget http://svn.stmlabs.com/svn/raspbmc/release/kernel/logo_linux_clut224.ppm -O drivers/video/logo/logo_linux_clut224.ppm
mkdir -p ${RAMFSDIR}
wget http://download.raspbmc.com/downloads/bin/kernel/initramfs.tar
tar -xf initramfs.tar -C ${RAMFSDIR}
rm initramfs.tar
make ARCH=arm CROSS_COMPILE=${CCPREFIX} $cores
con=1
if [ $# -eq 1 ]
then
con=$1
fi
CONCURRENCY_LEVEL=$con DEB_HOST_ARCH=armhf make-kpkg --arch=arm --cross-compile ${CPREFIX} kernel-headers
mv *.deb ..\linux-headers-latest.deb.gz # make .deb.gz for md5 function
md5sum ..\linux-headers-latest.deb.gz > ..\linux-headers-latest.md5
cd ..
wget https://github.com/raspberrypi/firmware/tarball/master
tar -xzf master
rm master
# build fat partition tar
mkdir fat
cp raspberrypi-firmware*/boot/bootcode.bin fat/
cp raspberrypi-firmware*/boot/start_x.elf fat/
cp raspberrypi-firmware*/boot/LICENCE.broadcom fat/
cp raspberrypi-firmware*/boot/fixup_x.dat fat/
cp ${LINUXDIR}/arch/arm/boot/zImage fat/kernel.img
echo "dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootfstype=ext4 noatime quiet rootwait loglevel=1 sdhci-bcm2708.enable_llm=1 dwc_otg.microframe_schedule=1 dwc_otg.fiq_fix_enable=0 dwc_otg.fiq_split_enable=0 dwc_otg.trans_backoff=3000" >fat/cmdline.txt

cd fat
tar -czf kernel-vfat-latest-hardfp.tar.gz *
md5sum kernel-vfat-latest-hardfp.tar.gz > kernel-vfat-latest-hardfp.md5
mv kernel-vfat* ..
cd ..
# build rootfs tar
mkdir -p rootfs/opt/vc/bin
cp -R raspberrypi-firmware*/hardfp/opt/vc/bin rootfs/opt/vc
make -C $LINUXDIR ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=../rootfs modules_install
make -C $LINUXDIR ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_HDR_PATH=../rootfs/usr headers_install
cd rootfs
MODULEDIR=lib/modules/$(ls lib/modules)
rm -rf $MODULEDIR/build
rm -rf $MODULEDIR/source
mkdir -p $MODULEDIR/build
ln -sf /usr/include $MODULEDIR/build/include
tar -czf kernel-rootfs-latest-hardfp.tar.gz *
md5sum kernel-rootfs-latest-hardfp.tar.gz > kernel-rootfs-latest-hardfp.md5
mv kernel-rootfs* ..
cd ..
