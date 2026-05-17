#!/usr/bin/env python3
"""Inject Jieli speakerphone quirk into kernel quirks-table.h."""

import sys
import os

def main():
    if len(sys.argv) != 3:
        print("Usage: {} <quirks-table.h> <quirk-entry.h>".format(sys.argv[0]),
              file=sys.stderr)
        sys.exit(1)

    target = sys.argv[1]
    entry_file = sys.argv[2]

    if not os.path.exists(target):
        print("ERROR: {} not found".format(target), file=sys.stderr)
        sys.exit(1)

    with open(target, 'r') as f:
        content = f.read()

    # Idempotent: skip if already patched
    if '0x4c4a, 0x4155' in content:
        print("Already patched: {}".format(target))
        return

    with open(entry_file, 'r') as f:
        entry = f.read()

    # Find insertion point: before #undef lines at end of file
    lines = content.split('\n')
    insert_idx = len(lines)
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].startswith('#undef'):
            insert_idx = i
        elif lines[i].strip() and not lines[i].startswith('#undef'):
            break

    lines.insert(insert_idx, entry.rstrip('\n'))

    with open(target, 'w') as f:
        f.write('\n'.join(lines))

    print("Patched: {} (inserted Jieli quirk at line {})".format(target, insert_idx))

if __name__ == '__main__':
    main()
