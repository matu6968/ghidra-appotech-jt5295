#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	printf 'usage: %s GHIDRA_INSTALL_DIR\n' "$0" >&2
	exit 2
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ghidra_dir="$(cd -- "$1" && pwd)"
module_dir="$ghidra_dir/Ghidra/Processors/OpenRISC/data/languages"
ldefs="$module_dir/OpenRISC.ldefs"
sla="$repo_dir/data/languages/OpenRISC_LE.sla"
spec="$repo_dir/data/languages/OpenRISC_LE.slaspec"

[[ -f "$ldefs" ]] || { echo "OpenRISC language module not found: $ldefs" >&2; exit 1; }
[[ -s "$sla" ]] || { echo "Build OpenRISC_LE.sla first" >&2; exit 1; }
[[ -s "$spec" ]] || { echo "Missing OpenRISC_LE.slaspec" >&2; exit 1; }

install -m 0644 "$sla" "$module_dir/OpenRISC_LE.sla"
install -m 0644 "$spec" "$module_dir/OpenRISC_LE.slaspec"
for file in OpenRISC_JT5295.sla OpenRISC_JT5295.slaspec OpenRISC_JT5295.cspec OpenRISC_ORBIS32.sinc; do
    install -m 0644 "$repo_dir/data/languages/$file" "$module_dir/$file"
done

python3 - "$ldefs" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text()
language_id = 'id="OpenRISC:LE:32:default"'

if language_id not in text:
    entry = '''  <language processor="OpenRISC"
            endian="little"
            size="32"
            variant="default"
            version="1.0"
            slafile="OpenRISC_LE.sla"
            processorspec="OpenRISC.pspec"
            id="OpenRISC:LE:32:default">
    <description>OpenRISC 1000 ORBIS32 LE (AppoTech firmware word order)</description>
    <compiler name="default" spec="OpenRISC.cspec" id="default" />
  </language>
'''
    closing = "</language_definitions>"
    if closing not in text:
        raise SystemExit(f"Missing {closing} in {path}")
    text = text.replace(closing, entry + closing, 1)
    path.write_text(text)
elif 'slafile="OpenRISC_LE.sla"' not in text:
    raise SystemExit(f"{language_id} exists but points at another SLEIGH file")
path.write_text(text)
language_id = 'id="OpenRISC:LE:32:JT5295"'
if language_id not in text:
    entry = '''  <language processor="OpenRISC" endian="little" size="32"
            variant="JT5295" version="1.0" slafile="OpenRISC_JT5295.sla"
            processorspec="OpenRISC.pspec" id="OpenRISC:LE:32:JT5295">
    <description>AppoTech JT5295: little endian, no delay slots, PC+4 link</description>
    <compiler name="SDK GCC 16" spec="OpenRISC_JT5295.cspec" id="gcc" />
  </language>
'''
    text = text.replace('</language_definitions>', entry + '</language_definitions>', 1)
    path.write_text(text)
PY
printf 'Installed OpenRISC LE and JT5295 languages into %s\nRestart Ghidra to load the new language.\n' "$ghidra_dir"
