# Speakerphone Jieli UACDemoV1.0 DKMS

DKMS module that adds explicit USB Audio quirk support for the **Jieli Technology UACDemoV1.0**
speakerphone (USB ID: `4c4a:4155`) to the Linux kernel's `snd-usb-audio` driver.

## Why?

The Jieli UACDemoV1.0 is a USB Audio Class compliant speakerphone that works with the
generic `snd-usb-audio` driver's class match, but benefits from an explicit quirk entry for:

- Proper device identification (vendor/product names in ALSA)
- Correct interface mapping (audio playback on iface 1, capture on iface 2, HID ignored on iface 3)
- Future-proofing against kernel changes to generic class matching

## Device Info

| Property | Value |
|----------|-------|
| Vendor | Jieli Technology |
| Product | UACDemoV1.0 |
| USB ID | `4c4a:4155` |
| Playback | 48kHz, 16-bit, Stereo (iface 1) |
| Capture | 48kHz, 16-bit, Mono (iface 2) |
| HID | Interface 3 (ignored) |
| Bus Powered | 400mA max |

## Requirements

- **DKMS** (`dkms` package)
- **Kernel headers** for the running kernel
- **Kernel source tree** — one of:
  - `/lib/modules/$(uname -r)/source/` (symlink to full source)
  - `/usr/src/linux-$(uname -r)/`
  - `linux-source-$(uname -r)` package (will be extracted automatically)

On Armbian:
```bash
sudo apt install dkms linux-headers-current-meson64 linux-source-$(uname -r | cut -d. -f1-2)
```

## Install

```bash
# Clone
git clone https://github.com/VladimirHulagov/speakerphone-Jieli-UACDemoV1-dkms.git
cd speakerphone-Jieli-UACDemoV1-dkms

# Install DKMS module
sudo dkms add .
sudo dkms install speakerphone-jieli/1.0.0

# Reload the driver
sudo modprobe -r snd-usb-audio
sudo modprobe snd-usb-audio

# Plug in the speakerphone — it should be detected with proper names
```

## Verify

```bash
# Check the module is loaded
modinfo snd-usb-audio | grep -i jieli || cat /proc/asound/cards

# Check mixer
amixer -c 1 contents
```

## Uninstall

```bash
sudo dkms remove speakerphone-jieli/1.0.0 --all
sudo rm -rf /usr/src/speakerphone-jieli-1.0.0
```

## How It Works

The DKMS module rebuilds `snd-usb-audio.ko` from the running kernel's source tree
with an additional quirk entry in `sound/usb/quirks-table.h`:

```c
/* Jieli Technology UACDemoV1.0 Speakerphone (4c4a:4155) */
{
    USB_AUDIO_DEVICE(0x4c4a, 0x4155),
    QUIRK_DRIVER_INFO {
        .vendor_name = "Jieli Technology",
        .product_name = "Speakerphone",
        QUIRK_DATA_COMPOSITE {
            { QUIRK_DATA_STANDARD_AUDIO(1) },
            { QUIRK_DATA_STANDARD_AUDIO(2) },
            { QUIRK_DATA_IGNORE(3) },
            QUIRK_COMPOSITE_END
        }
    }
},
```

On kernel updates, DKMS automatically rebuilds the module with the quirk applied.

## License

GPL-2.0-or-later (same as the Linux kernel's snd-usb-audio driver)
