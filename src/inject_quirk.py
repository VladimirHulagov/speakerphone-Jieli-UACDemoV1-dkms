#!/usr/bin/env python3
""Inject Jieli speakerphone quirk entry into kernel's quirks-table.h.
Usage: inject_quirk.py <quirks_table_h> <quirk_entry_h>

Inserts the quirk entry before the #undef lines at the end of the file.
Skips if already present (idempotent).
""

import sys
import os

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <quirks-table.h> <quirk-entry.h>", file=sys.stderr)
        sys.exit(1)

    target = sys.argv[1]
    entry_file = sys.argv[2]

    if not os.path.exists(target):
        print(f"ERROR: {target} not found", file=sys.stderr)
        sys.exit(1)

    with open(target, 'r') as f:
        content = f.read()

    # Idempotent: skip if already patched
    if '0x4c4a, 0x4155' in content or 'Jieli' in content:
        print(f"Already patched: {target}")
        return

    with open(entry_file, 'r') as f:
        entry = f.read()

    # Find the insertion point: before #undef lines at the end
    lines = content.split('\n')
    insert_idx = len(lines)
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].startswith('#undef'):
            insert_idx = i
        elif lines[i].strip() and not lines[i].startswith('#undef'):
            break

    # Insert our entry
    lines.insert(insert_idx, entry.rstrip('\n'))

    with open(target, 'w') as f:
        f.write('\n'.join(lines))

    print(f"Patched: {target} (inserted Jieli quirk at line {insert_idx})")

if __name__ == '__main__':
    main()
