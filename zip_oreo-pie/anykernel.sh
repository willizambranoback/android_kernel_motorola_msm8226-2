# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers
# Modified by @willizambrano

## AnyKernel setup

# shell variables
block=/dev/block/platform/msm_sdcc.1/by-name/boot;
is_slot_device=0;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk;

## AnyKernel install
dump_boot;

# begin ramdisk changes

# fstab.qcom (increased zram size)
backup_file fstab.qcom;
replace_file fstab.qcom 640 fstab.qcom;

# end ramdisk changes

write_boot;

## end install

