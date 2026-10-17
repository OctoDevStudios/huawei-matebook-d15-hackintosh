# Modified kexts in `EFI-Tahoe`

Four kexts in `EFI-Tahoe/OC/Kexts` are not the upstream release binaries. The changes are
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

## VoodooInput — optional "instant cursor" mode (`-vi_mouse`)

- Source: [acidanthera/VoodooInput](https://github.com/acidanthera/VoodooInput) 1.1.6 (the copy inside
  `VoodooI2C.kext/Contents/PlugIns`). Patch: [`VoodooInput-mouse-mode.patch`](VoodooInput-mouse-mode.patch).
- Why: on macOS Tahoe the cursor driven through Apple's multitouch stack (VoodooInput emulates a
  Magic Trackpad 2) intermittently feels smoothed / late, while a USB mouse on the same machine is
  instant. Measurements showed the touchpad reports and the generated events are on time; the
  difference is in how Tahoe processes multitouch input. Sonoma with the same kexts is not affected.
- What it does: with the boot-arg `-vi_mouse`, VoodooInput computes the pointer motion, two-finger
  scrolling and clicks itself and sends them through its relative pointer device (the same path as a
  mouse). One finger moves the cursor, a click is a left click, a click with two fingers (or in the
  bottom-right corner) is a right click, two fingers scroll. Three/four-finger gestures, pinch,
  Force Touch and Apple's scroll momentum are not available in this mode. Cursor speed is set in
  System Settings > Mouse.
- **Without `-vi_mouse` the kext behaves exactly like upstream 1.1.6** (full Apple gestures).
- Licence: GPL-2.0, like VoodooInput (patch provided as source above).
