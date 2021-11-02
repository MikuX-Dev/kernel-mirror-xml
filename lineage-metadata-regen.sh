#!/usr/bin/env bash

MIRROR_ROOT=${MIRROR_ROOT:=/mnt/mirrors}

LINEAGE_MIRROR=${MIRROR_ROOT}/lineage
MIRROR_MANIFEST=${MIRROR_ROOT}/lineage-mirror-manifest
KERNEL_MIRROR_MANIFEST=${MIRROR_ROOT}/kernel-mirror-manifest

kernels=`grep kernel ${MIRROR_MANIFEST}/default.xml | grep -v -e 'android_device' -e 'android_external' -e 'android_hardware' -e 'hardware_nvidia' | sed -e 's#  <project name="LineageOS/##g' -e 's#" />##g'`

echo -e "declare -A kernel_map\n" > ${KERNEL_MIRROR_MANIFEST}/lineage-metadata

for kernel in $kernels; do
	# set current VERSION, PATCHLEVEL
	# force $TMPFILEs below to be in local directory: a slash character prevents
	# the dot command from using the search path.
	TMPFILE=`mktemp ./.tmpver.XXXXXX` || { echo "cannot make temp file" ; exit 1; }
	curl -s https://raw.githubusercontent.com/LineageOS/$kernel/HEAD/Makefile | grep -E "^(VERSION|PATCHLEVEL)" > $TMPFILE
	tr -d [:blank:] < $TMPFILE > $TMPFILE.1
	. $TMPFILE.1
	rm -f $TMPFILE*
	if [ -z "$VERSION" -o -z "$PATCHLEVEL" ] ; then
		echo "unable to determine current kernel version for" $kernel >&2
		continue;
	fi

	KERNEL_VERSION="$VERSION.$PATCHLEVEL"

	echo "kernel_map["$kernel"]="$KERNEL_VERSION >> ${KERNEL_MIRROR_MANIFEST}/lineage-metadata

	unset VERSION
	unset PATCHLEVEL
done
