#!/sbin/sh

busybox mount /system;

ExpectedCodename=`cat /tmp/anykernel/device.txt`;

file_getprop() {
	grep ^$2 $1 | cut -d= -f2;
}	

codename=`grep ^ro.product.name /system/build.prop | cut -d= -f2 | cut -d_ -f2`;
sdk=`grep ^ro.build.version.sdk /system/build.prop | cut -d= -f2`;
rom=`grep ^ro.product.name /system/build.prop | cut -d= -f2 | cut -d_ -f1`;
release=`grep ^ro.build.version.release /system/build.prop | cut -d= -f2`;
buildid=`grep ^ro.build.display.id /system/build.prop | cut -d= -f2`;

case $codename in
	"falcon")
		device="Moto G (1st Generation)";;
	"titan")
		device="Moto G (2nd Generation)";;
esac;

case $sdk in
	"26" | "27")
		codename2="Oreo";;
esac;

case $rom in
	"cm")
		rom="CyanogenMod";;
	"lineage")
		rom="LineageOS";;
	"aosip")
		rom="AOSiP";;
	"aosp" | "full")
		if [ "$(file_getprop /system/build.prop ro.extended.version)" != "" ]; then
			rom="AospExtended";
		else
			rom="AOSP";
		fi;;
	"aicp")
		rom="AICP";;
	"pa")
		rom="AOSPA";;
	"viper")
		rom="ViperOS";;
	"du")
		rom="Dirty Unicorns";;
	"mk")
		rom="MoKee Open Source";;
	"aokp")
		rom="AOKP";;
	"tesla")
		rom="Tesla";;
	"validus")
		rom="Validus";;
	"tipsy")
		rom="Tipsy";;
	"orion")
		rom="OrionOS";;
	"exodus")
		rom="Exodus";;
	"krexus")
		rom="Krexus-CAF";;
	"vanir")
		rom="VanirAOSP";;
	"commotio")
		rom="VanirAOSP Commotio";;
	"aoscp")
		rom="CypherOS";;
	"xosp")
		rom="XOSP";;
	"slim")
		rom="Slim";;
	"omni")
		rom="OmniROM";;
	"xpe")
		rom="XPerience";;
	"citrus")
		rom="Citrus-CAF";;
	*)
		rom="Unknown";;
esac;

# crDroid & RR
if [ "$(file_getprop /system/build.prop ro.rr.version)" != "" ]; then
	rom="Resurrection Remix";
elif [ "$(file_getprop /system/build.prop ro.crdroid.version)" != "" ]; then
	rom="crDroid";
fi;

# MIUI
if [ "$(file_getprop /system/build.prop ro.miui.version.name)" != "" ] || 
	[ "$(file_getprop /system/build.prop ro.miui.ui.version.name)" != "" ]; then
	rom="MIUI";
fi;

# Pure Nexus
if [ "$(file_getprop /system/build.prop ro.pure.version)" != "" ]; then
	rom="Pure Nexus";
fi;

cat << EOF > /tmp/anykernel/devicedata.txt;
device.model=$device
device.codename=$codename
device.androidver=$release
device.androidcn=$codename2
device.rom=$rom
device.sdk=$sdk
device.buildid=$buildid
EOF

# First step: check if we're installing this kernel to the device it was built for
if [[ $codename = $ExpectedCodename ]]; then
	# Second step: check if the device is running Marshmallow, Nougat or Oreo
	if [[ $sdk = "23" ]] || [[ $sdk = "24" ]] || [[ $sdk = "25" ]] || [[ $sdk = "26" ]] || [[ $sdk = "27" ]]; then
		# Third step: check if we're not running a stock rom
		if [[ "$(printf $buildid | grep -i 'Stock')" = "" ]]; then
			# "Error" code 0: all checks passed, proceed with installation
			echo "0" > /tmp/anykernel/errorcode;
		else
			# Error code 3: not a CM- or AOSP-based rom
			echo "3" > /tmp/anykernel/errorcode;
		fi;
	else
		# Error code 2: incompatible Android version
		echo "2" > /tmp/anykernel/errorcode;
	fi;
else
	# Error code 1: incompatible device
	echo "1" > /tmp/anykernel/errorcode;
fi;
