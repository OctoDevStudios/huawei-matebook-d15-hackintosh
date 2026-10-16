# Modified kexts in `EFI-Tahoe`

Three kexts in `EFI-Tahoe/OC/Kexts` are not the upstream release binaries. The changes are
small and listed here, with the patches, so they can be rebuilt or reviewed.

## AirportItlwm — `-itlwm_no160`

- Source: [laobamac/itlwm](https://github.com/laobamac/itlwm) at `bbe368e` (Tahoe / IO80211FamilyV2 build).
- Patch: [`itlwm-no160.patch`](itlwm-no160.patch) adds the boot-arg `-itlwm_no160`, which stops the
  card from advertising 160 MHz channels (the 9560 is then used at 80 MHz, like the Sonoma build).
- Why: at 160 MHz the Intel Wireless-AC 9560 negotiated MCS 2–3 and only reached 25–43 Mbit/s;
  at 80 MHz it uses MCS 7 and reaches ~375 Mbit/s down / ~155 Mbit/s up on the same router.
- Build without Xcode: [`build-airportitlwm-tahoe.sh`](build-airportitlwm-tahoe.sh) (sources list
  in `tahoe-srcs.txt`, needs [MacKernelSDK](https://github.com/acidanthera/MacKernelSDK)).
- Licence: itlwm is GPL-2.0; the patch is under the same licence.

## BlueToolFixup — legacy chipset pattern skipped on Sequoia+

- Source: [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) 2.7.2.
- Patch: [`BlueToolFixup-tahoe.patch`](BlueToolFixup-tahoe.patch). On Tahoe the old (Monterey)
  "bad chipset" byte pattern also matches unrelated code in `bluetoothd`, which then crashes
  (`apfs_pagein` error 94 / KERN_MEMORY_ERROR). The pattern is now only applied before Sequoia.
- Licence: BSD-3-Clause, like BrcmPatchRAM.

## IntelBTPatcher 2.5.0

- Built from [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware)
  master (no release yet). It prepares the USB memory descriptor on Sequoia+; the 2.4.0 release
  panics on Tahoe when the webcam starts (`UVCAssistant`).
