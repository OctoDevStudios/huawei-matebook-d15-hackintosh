# Huawei MateBook D15 2020 — OpenCore EFI (macOS Tahoe & Sonoma)

Ready-to-use OpenCore EFIs for the **Huawei MateBook D15 2020** (i5-10210U, board BOHB-WAX9),
with **working internal audio and fingerprint reader** thanks to two custom drivers:

- **[MateBookAudio](https://github.com/OctoDevStudios/MateBookAudio)** — Intel SOF + ES8336
  audio: speakers, headphones, internal and headset microphones, calls.
- **[MateBookFP](https://github.com/OctoDevStudios/MateBookFP)** — Goodix GXFP51A0 fingerprint
  reader: `sudo` and lock-screen unlock.

## Which folder?

The two macOS versions need different kexts, boot-args and SMBIOS, so there is one EFI per version.
Take the folder for your macOS and copy it to the EFI partition **renamed to `EFI`**.

| | [`EFI-Tahoe`](EFI-Tahoe) | [`EFI-Sonoma`](EFI-Sonoma) |
|---|---|---|
| macOS | Tahoe 26.7.1 | Sonoma 14.8.x |
| OpenCore | 1.0.8 | 1.0.5 |
| SMBIOS | MacBookPro16,2 | MacBookAir9,1 |
| Wi-Fi | AirportItlwm (Tahoe build, 80 MHz) | AirportItlwm 2.3.0 |
| Backlight fix | `-igfxblr` | `-igfxblt` |

Machine: Huawei MateBook D15 2020, i5-10210U (Comet Lake), UHD 620, 1080p.
**The serials in this repo are placeholders** — generate your own (see Install).

Why MacBookPro16,2 on Tahoe: Tahoe dropped the Intel MacBook Air, the closest supported model
is the 13" MacBook Pro 2020 (Comet/Ice Lake class, Intel iGPU).

## What works

| Feature | Status | Notes |
|---|---|---|
| Internal speakers | ✅ | MateBookAudio kext + HAL plugin, calibrated EQ |
| Headphones (hot-plug) | ✅ | *Headphones* shown in Sound settings |
| Internal microphone | ✅ | |
| Calls (FaceTime, Zoom…), echo cancellation | ✅ | MateBookAudio 1.1.0 |
| Headset microphone | ✅ | *External Microphone* shown when plugged in |
| Fingerprint for `sudo` and the lock screen | ✅ | MateBookFP, needs its userspace part |
| Sleep / wake, lid | ✅ | |
| Intel Wi-Fi / Bluetooth | ✅ | AirportItlwm, IntelBluetoothFirmware. Tahoe: ~375 Mbit/s at 80 MHz |
| Trackpad (I2C), keyboard, brightness keys | ✅ | VoodooI2C (GPIO interrupts), VoodooPS2, BrightnessKeys |
| Battery, CPU power management | ✅ | SMCBatteryManager, CPUFriend |
| iGPU acceleration (Metal 3) | ✅ | WhateverGreen |
| HDMI | ✅ | |
| Fingerprint at the boot login window | ❌ | password required, like Touch ID after a restart |
| AirDrop / Handoff | ❌ | needs a Broadcom Wi-Fi card |

**Known issue:** after waking from sleep, the screen stays black ~2 s longer than on a real Mac
(Apple's framebuffer waits for a panel acknowledgement this display never sends, then times out).

## Install

1. Pick `EFI-Tahoe` or `EFI-Sonoma` and copy it as `EFI` (keep a backup of your current EFI).
2. **Generate your own SMBIOS** with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) — model
   `MacBookPro16,2` for Tahoe, `MacBookAir9,1` for Sonoma — and fill `EFI/OC/config.plist` →
   `PlatformInfo > Generic`: `SystemSerialNumber`, `MLB`, `SystemUUID`, `ROM` (use your Wi-Fi MAC
   address for `ROM`).
3. Change `itlwm_cc=FR` in `boot-args` to your own country code.
4. Validate with `ocvalidate EFI/OC/config.plist` (OpenCore 1.0.8 for Tahoe, 1.0.5 for Sonoma),
   copy `EFI/` to the EFI partition, boot macOS.
5. Install the macOS-side parts:
   - Audio: `sudo install/install.sh` from [MateBookAudio](https://github.com/OctoDevStudios/MateBookAudio).
   - Fingerprint: the steps in [MateBookFP](https://github.com/OctoDevStudios/MateBookFP#install).

A zip of each EFI is attached to the [releases](../../releases).

## Tahoe notes

- **Boot-args** (`EFI-Tahoe`): `-igfxblr` (Tahoe's framebuffer calls `WriteRegister32` again, the
  Sonoma `-igfxblt` fix fails and the panel stays dim for minutes), `-itlwm_no160` (see below),
  `revpatch=cpuname,sbvmm`, `-lilubetaall -ibtcompatbeta` (Lilu plugins not yet flagged for Tahoe).
- **Bluetooth:** since Sequoia, `-btlfxnvramcheck` no longer works; the NVRAM variables
  `bluetoothExternalDongleFailed` and `bluetoothInternalControllerInfo` are set in `NVRAM > Add`.
- **Modified kexts** (AirportItlwm `-itlwm_no160`, BlueToolFixup, IntelBTPatcher 2.5.0): sources of
  the changes and why in [extras/patches](extras/patches).
- No OpenCore picker (like a real Mac): hold **Option/Alt** at boot to show it.

## Changes from the original EFI (Sonoma)

Based on [lastant/huawei-d15-2020-opencore-efi](https://github.com/lastant/huawei-d15-2020-opencore-efi):

- Only the kexts / SSDTs / drivers that are actually loaded are kept (82 MB → 35 MB). Removed:
  `itlwm`, `AppleALC` (useless: there is no HDA codec), `RtWlanU*`, Ethernet,
  `USBInjectAll`/`USBMap`, unused SSDTs.
- Added `MateBookAudio.kext`, `MateBookFP.kext`, `RestrictEvents.kext` (`revpatch=cpuname`).
- About This Mac: real CPU name, "Intel UHD Graphics 620", Core i5 `ProcessorType`.
- `ResetNvramEntry.efi` moved to drivers, debug boot-args removed, SIP enabled.

`extras/block-macos15-updates.sh` (+ LaunchDaemon plist, **Sonoma only**) optionally keeps the machine on Sonoma
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
