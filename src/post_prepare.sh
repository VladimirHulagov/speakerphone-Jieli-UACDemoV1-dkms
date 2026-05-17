#!/bin/bash
# Prepare patched snd-usb-audio source for DKMS build
set -e

KVER="$1"
KSRC="$2"  # kernel source (from dkms.conf)
BDIR="$3"  # DKMS build directory

# Find kernel source
for d in /lib/modules/$KVER/source /usr/src/linux-source-$(echo $KVER | cut -d. -f1-2) /usr/src/linux-source-$KVER; do
    if [ -f "$d/sound/usb/card.c" ]; then
        KSRC="$d"
        break
    fi
done

if [ -z "$KSRC" ] || [ ! -f "$KSRC/sound/usb/card.c" ]; then
    echo "ERROR: Kernel source not found for $KVER" >&2
    exit 1
fi

echo "==> Patching snd-usb-audio from $KSRC"

# Copy sound/usb into build dir
cp -rL "$KSRC/sound/usb" "$BDIR/sound/usb"

# Inject Jieli quirk
python3 "$BDIR/src/inject_quirk.py" "$BDIR/sound/usb/quirks-table.h" "$BDIR/src/jieli_quirk.h"

echo "==> Patched successfully"
