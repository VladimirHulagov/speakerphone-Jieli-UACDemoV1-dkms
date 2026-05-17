# Speakerphone Jieli UACDemoV1.0 — DKMS Module

DKMS package that preserves the **original Armbian `snd-usb-audio` kernel module** for the Jieli Technology UACDemoV1.0 speakerphone (USB `4c4a:4155`).

## Why prebuilt?

Building `snd-usb-audio` from the vanilla `linux-source-6.18` Debian package produces a module where **audio capture is broken** — every isochronous URB frame returns `EOVERFLOW (-75)`. The original module compiled by Armbian works perfectly. The difference is in the kernel build configuration and/or patches that Armbian applies but are not available in the vanilla source tarball.

Since we cannot reproduce the exact Armbian build environment, we ship the known-working binary directly.

## What's included

| File | Description |
|------|-------------|
| `prebuilt/snd-usb-audio.ko` | Original Armbian module (7.2 MB, with debug relocation data) |
| `prebuilt/snd-usbmidi-lib.ko` | Original Armbian MIDI library module |

## Kernel version

These modules were built for **`6.18.10-current-meson64`** (Armbian, aarch64).
DKMS will refuse to install on a different kernel (`BUILD_EXCLUSIVE_KERNEL`).

## Installation

```bash
sudo dkms add .
sudo dkms install speakerphone-jieli/1.0.0
sudo modprobe -r snd-usb-audio
sudo modprobe snd-usb-audio
```

## Device info

- **Vendor**: Jieli Technology (`4c4a`)
- **Product**: UACDemoV1.0 Speakerphone (`4155`)
- **ALSA**: Card 1, native 48kHz, use `plughw:1,0` for 16kHz resampling
- **Kernel builtin quirk**: `GET_SAMPLE_RATE` + `GENERIC_IMPLICIT_FB` (applied automatically)

## Intercom bridge

Used with a full-duplex TCP↔ALSA bridge (`/opt/intercom_bridge.py`) that connects the speakerphone to an ESP32 intercom device at `10.1.30.57:6054`.

Audio format: 16kHz S16_LE mono, 1024-byte chunks, resampled to/from 48kHz via `plughw` ALSA plugin.
