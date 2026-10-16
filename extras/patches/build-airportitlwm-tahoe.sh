#!/bin/bash
# Build AirportItlwm (Tahoe / IO80211FAMILY_V2) without Xcode, from laobamac/itlwm @ bbe368e + itlwm-no160.patch.
# Usage: SRC=path/to/itlwm MKSDK=path/to/MacKernelSDK ./build-airportitlwm-tahoe.sh   (sources list: tahoe-srcs.txt)
set -e
R=${SRC:?set SRC to the itlwm source tree}
SDK=${MKSDK:?set MKSDK to MacKernelSDK}
O=${OBJ:-$PWD/obj}
mkdir -p $O
cd $R
[ -f include/FwBinary.cpp ] || python3 -I scripts/zlib_compress_fw.py include/FwBinary.cpp itlwm/firmware/
# header-map emulation: every dir holding headers
INC=""
for d in $(find itlwm itl80211 include AirportItlwm -name '*.h' -o -name '*.hpp' | xargs -n1 dirname | sort -u); do INC="$INC -I$R/$d"; done
SYS="-isystem $R/itl80211/openbsd -isystem $R/itl80211 -isystem $R/include"
DEFS="-DKERNEL -DKERNEL_PRIVATE -DDRIVER_PRIVATE -DAPPLE -DNeXT -DITLWM_VERSION=\"2.4.0\" -DGIT_COMMIT=\"bbe368e-no160\" -DIEEE80211_STA_ONLY -DAIRPORT_WCL -DAIRPORT_VTD -D__IO80211_TARGET=__MAC_26_0 -DAIRPORT -D__PRIVATE_SPI__ -DIO80211FAMILY_V2"
CF="-target x86_64-apple-macos10.15 -x c++ -std=gnu++14 -O1 -mkernel -fapple-kext -fno-builtin -fno-common -nostdinc -nostdinc++ -I$SDK/Headers -Wno-everything -include $R/itlwm/PrivateSPI.pch -fno-rtti -fno-exceptions -mno-red-zone"
OBJS=""
pids=0
while read f; do
  [ "$f" = "(null)" ] && continue
  p=$(find itlwm itl80211 include AirportItlwm -name "$f" | head -1)
  [ -z "$p" ] && { echo "MISSING $f"; exit 1; }
  o=$O/${p//\//_}.o
  OBJS="$OBJS $o"
  if [ ! -f "$o" -o "$p" -nt "$o" ]; then
    clang $CF $DEFS $INC $SYS -c "$p" -o "$o" 2> "$o.log" || { echo "FAIL $p"; head -30 "$o.log"; exit 1; } &
    pids=$((pids+1)); [ $((pids % 8)) -eq 0 ] && wait
  fi
done < $(dirname "$0")/tahoe-srcs.txt
wait
for o in $OBJS; do [ -f $o ] || { echo "no obj $o"; cat $o.log | head -30; exit 1; }; done
echo "$OBJS" > $O/objs.txt

# --- link ---
B=${OBJ:-$PWD/obj}/..
R=${SRC}
SDK=${MKSDK}
K=$B/out/AirportItlwm.kext
rm -rf $K; mkdir -p $K/Contents/MacOS
cat > ${OBJ:-$PWD/obj}/kmod_info.c <<'C'
#include <mach/mach_types.h>
extern kern_return_t _start(kmod_info_t *ki, void *data);
extern kern_return_t _stop(kmod_info_t *ki, void *data);
__attribute__((visibility("default"))) KMOD_EXPLICIT_DECL(com.zxystd.AirportItlwm, "2.4.0", _start, _stop)
__private_extern__ kmod_start_func_t *_realmain = 0;
__private_extern__ kmod_stop_func_t *_antimain = 0;
__private_extern__ int _kext_apple_cc = __APPLE_CC__;
C
clang -target x86_64-apple-macos10.15 -mkernel -nostdinc -I$SDK/Headers -DKERNEL -c ${OBJ:-$PWD/obj}/kmod_info.c -o ${OBJ:-$PWD/obj}/kmod_info.o
clang++ -target x86_64-apple-macos10.15 -mkernel -nostdlib -Xlinker -kext -o $K/Contents/MacOS/AirportItlwm $(cat ${OBJ:-$PWD/obj}/objs.txt) ${OBJ:-$PWD/obj}/kmod_info.o -L$SDK/Library/x86_64 -lkmod
sed -e 's/$(EXECUTABLE_NAME)/AirportItlwm/g;s/$(PRODUCT_BUNDLE_IDENTIFIER)/com.zxystd.AirportItlwm/g;s/$(PRODUCT_NAME)/AirportItlwm/g;s/$(MODULE_VERSION)/2.4.0/g;s/$(CURRENT_PROJECT_VERSION)/2.4.0/g;s/$(DEVELOPMENT_LANGUAGE)/en/g;s/${PRODUCT_NAME}/AirportItlwm/g;s/$(PRODUCT_BUNDLE_PACKAGE_TYPE)/KEXT/g;s/$(MACOSX_DEPLOYMENT_TARGET)/10.15/g' $R/AirportItlwm/WCL/Info.plist > $K/Contents/Info.plist
grep -n '\$(' $K/Contents/Info.plist || true
