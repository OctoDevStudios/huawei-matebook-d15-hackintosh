# Huawei MateBook D15 2020 — OpenCore EFI (macOS Sonoma)

Ready-to-use OpenCore EFI for the **Huawei MateBook D15 2020** (i5-10210U, board BOHB-WAX9),
with **working internal audio and fingerprint reader** thanks to two custom drivers:

- **[MateBookAudio](https://github.com/OctoDevStudios/MateBookAudio)** — Intel SOF + ES8336
  audio: speakers, headphones, internal and headset microphones.
- **[MateBookFP](https://github.com/OctoDevStudios/MateBookFP)** — Goodix GXFP51A0 fingerprint
  reader: `sudo` and lock-screen unlock.

| | |
|---|---|
| Machine | Huawei MateBook D15 2020, i5-10210U (Comet Lake), UHD 620, 1080p |
| macOS | Sonoma 14.8.x |
| OpenCore | 1.0.5 (`ocvalidate` clean) |
| SMBIOS | MacBookAir9,1 — **the serials in this repo are placeholders** |

## What works

| Feature | Status | Notes |
|---|---|---|
| Internal speakers | ✅ | MateBookAudio kext + HAL plugin, calibrated EQ |
| Headphones (hot-plug) | ✅ | *Headphones* shown in Sound settings |
| Internal microphone | ✅ | |
| Headset microphone | ✅ | *External Microphone* shown when plugged in |
| Fingerprint for `sudo` and the lock screen | ✅ | MateBookFP, needs its userspace part |
| Sleep / wake, lid | ✅ | |
| Intel Wi-Fi / Bluetooth | ✅ | AirportItlwm, IntelBluetoothFirmware |
| Trackpad (I2C), keyboard, brightness keys | ✅ | VoodooI2C, VoodooPS2, BrightnessKeys |
| Battery, CPU power management | ✅ | SMCBatteryManager, CPUFriend |
| iGPU acceleration (Metal 3) | ✅ | WhateverGreen |
| HDMI | ✅ | |
| Fingerprint at the boot login window | ❌ | password required, like Touch ID after a restart |
| AirDrop / Handoff | ❌ | needs a Broadcom Wi-Fi card |

**Known issue:** after waking from sleep, the screen stays black ~2 s longer than on a real Mac
(Apple's framebuffer waits for a panel acknowledgement this display never sends, then times out).

## Install

1. **Generate your own SMBIOS** with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) (model
   `MacBookAir9,1`) and fill `EFI/OC/config.plist` → `PlatformInfo > Generic`:
   `SystemSerialNumber`, `MLB`, `SystemUUID`, `ROM` (use your Wi-Fi MAC address for `ROM`).
2. Change `itlwm_cc=FR` in `boot-args` to your own country code.
3. Validate with `ocvalidate EFI/OC/config.plist` (OpenCore 1.0.5), copy `EFI/` to the EFI
   partition, boot macOS.
4. Install the macOS-side parts:
   - Audio: `sudo install/install.sh` from [MateBookAudio](https://github.com/OctoDevStudios/MateBookAudio).
   - Fingerprint: the steps in [MateBookFP](https://github.com/OctoDevStudios/MateBookFP#install).

A zip of the EFI is attached to each [release](../../releases).

## Changes from the original EFI

Based on [lastant/huawei-d15-2020-opencore-efi](https://github.com/lastant/huawei-d15-2020-opencore-efi):

- Only the kexts / SSDTs / drivers that are actually loaded are kept (82 MB → 35 MB). Removed:
  `itlwm`, `AppleALC` (useless: there is no HDA codec), `RtWlanU*`, Ethernet,
  `USBInjectAll`/`USBMap`, unused SSDTs.
- Added `MateBookAudio.kext`, `MateBookFP.kext`, `RestrictEvents.kext` (`revpatch=cpuname`).
- About This Mac: real CPU name, "Intel UHD Graphics 620", Core i5 `ProcessorType`.
- `ResetNvramEntry.efi` moved to drivers, debug boot-args removed, SIP enabled.

`extras/block-macos15-updates.sh` (+ LaunchDaemon plist) optionally keeps the machine on Sonoma
by hiding the macOS 15+ upgrade; check for Sonoma security updates manually.

## Credits and licenses

- Base EFI: [lastant](https://github.com/lastant/huawei-d15-2020-opencore-efi).
- [OpenCore](https://github.com/acidanthera/OpenCorePkg) and kexts by
  [Acidanthera](https://github.com/acidanthera), [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C),
  [OpenIntelWireless](https://github.com/OpenIntelWireless), [USBToolBox](https://github.com/USBToolBox)
  and others, under their own licenses.
- `MateBookAudio.kext` embeds Sound Open Firmware (see
  [LICENSES/LICENCE.SOF-Intel](LICENSES/LICENCE.SOF-Intel)); `MateBookAudio` and `MateBookFP`
  are MIT, see their repositories.
- No personal identifier (serial numbers, MLB, UUID, ROM) is included.
