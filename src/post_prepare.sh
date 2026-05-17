#!/bin/bash
# Prepare patched snd-usb-audio source for DKMS build
set -e

BDIR="$(cd "$(dirname "$0")/.." && pwd)"

# Get kernel version from the dkms build environment or uname
KVER="${kernelver:-$(uname -r)}"

# Find kernel source
KSRC=""
for d in /lib/modules/$KVER/source          /usr/src/linux-source-$(echo $KVER | cut -d. -f1-2)          /usr/src/linux-source-$KVER          /usr/src/linux-$KVER; do
    if [ -f "$d/sound/usb/card.c" ]; then
        KSRC="$d"
        break
    fi
done

if [ -z "$KSRC" ]; then
    echo "ERROR: Kernel source not found for $KVER" >&2
    echo "Tried: /lib/modules/$KVER/source, /usr/src/linux-source-$(echo $KVER | cut -d. -f1-2)" >&2
    exit 1
fi

echo "==> Patching snd-usb-audio from $KSRC"

# Copy sound/usb into build dir
mkdir -p "$BDIR/sound/usb"
cp -rL "$KSRC/sound/usb/"* "$BDIR/sound/usb/"

# Inject Jieli quirk
python3 "$BDIR/src/inject_quirk.py" "$BDIR/sound/usb/quirks-table.h" "$BDIR/src/jieli_quirk.h"

echo "==> Patched successfully"
