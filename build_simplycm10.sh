#!/bin/bash

if [ "$CPU_JOB_NUM" = "" ] ; then
	CPU_JOB_NUM=`grep -c processor /proc/cpuinfo`
fi

CUSTOMVERSION="SimplyCM10-vc-v1"
export KBUILD_BUILD_VERSION=$CUSTOMVERSION
LOCALVERSION_STRING="-$CUSTOMVERSION"
DEFCONFIG_STRING=cyanogenmod_epicmtd_defconfig

TOOLCHAIN=/mnt/data/linaro-android-eabi-1209/bin
TOOLCHAIN_PREFIX=arm-eabi-

PRJROOT=$PWD
KERNEL_BUILD_DIR=$PRJROOT/kernel
ZIP_BUILD_DIR=$PRJROOT/zip
KEXEC_BUILD_DIR=$PRJROOT/kexec-zip

case "$1" in
	clean)
		pushd $KERNEL_BUILD_DIR
		make V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX clean
		popd
		;;
	mrproper)
		pushd $KERNEL_BUILD_DIR
		make V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX clean
		make mrproper
		popd
		;;
	distclean)
		pushd $KERNEL_BUILD_DIR
		make V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX clean
		make distclean
		popd
		;;
	build)
		pushd $KERNEL_BUILD_DIR
		START_TIME=`date +%s`
		make ARCH=arm $DEFCONFIG_STRING
		make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX LOCALVERSION=$LOCALVERSION_STRING
		END_TIME=`date +%s`
		let "ELAPSED_TIME=$END_TIME-$START_TIME"
		echo "Total compile time is $ELAPSED_TIME seconds"
		cp arch/arm/boot/zImage $ZIP_BUILD_DIR
		popd
		;;
	zip)
		pushd $ZIP_BUILD_DIR
		cp $KERNEL_BUILD_DIR/arch/arm/boot/zImage $ZIP_BUILD_DIR
		rm -rf system
		mkdir -p system/lib/modules
		find $KERNEL_BUILD_DIR -name '*.ko' -exec cp '{}' system/lib/modules/ \; -exec echo "Found module: '{}'" \;
		$TOOLCHAIN/$TOOLCHAIN_PREFIX'strip' --strip-debug -v system/lib/modules/*
		rm $PRJROOT/$CUSTOMVERSION.zip
		zip -r $PRJROOT/$CUSTOMVERSION.zip ./*
		popd
		;;
	kexec-zip)
		pushd $KEXEC_BUILD_DIR
		cp $KERNEL_BUILD_DIR/arch/arm/boot/zImage $KEXEC_BUILD_DIR
		rm $PRJROOT/$CUSTOMVERSION-kexec.zip
		zip -r $PRJROOT/$CUSTOMVERSION-kexec.zip ./*
		popd
		;;
	*)
		echo "usage: [build|zip|clean|mrproper|distclean|kexec-zip]"
		;;
esac
