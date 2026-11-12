#!/bin/bash
# Switch the selected LEDE checkout's router defaults to fw4/nftables.
set -euo pipefail
source_root="${1:-${GITHUB_WORKSPACE:?}/openwrt}"
python3 - "$source_root/include/target.mk" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
lines = path.read_text().splitlines(keepends=True)
start = next((i for i, line in enumerate(lines)
              if line.startswith("DEFAULT_PACKAGES.router:=")), None)
if start is None:
    raise SystemExit("ERROR: DEFAULT_PACKAGES.router not found")
end = start
while lines[end].rstrip().endswith("\\"):
    end += 1
    if end >= len(lines):
        raise SystemExit("ERROR: unterminated DEFAULT_PACKAGES.router block")
value = "".join(lines[start:end + 1]).split(":=", 1)[1]
packages = re.sub(r"\\\r?\n", " ", value).split()
legacy = {"firewall", "iptables", "ip6tables", "ipset", "libip4tc", "libip6tc", "libxtables", "kmod-iptables", "kmod-ip6tables"}
packages = [name for name in packages
            if name not in legacy and not name.startswith(("iptables-", "ip6tables-", "kmod-ipt-"))]
for name in ("firewall4", "nftables-json", "kmod-nft-tproxy", "kmod-nft-socket", "kmod-nft-nat6", "kmod-nft-offload"):
    if name not in packages:
        packages.append(name)
block = "DEFAULT_PACKAGES.router:=\\\n\t" + " ".join(packages) + "\n"
path.write_text("".join(lines[:start]) + block + "".join(lines[end + 1:]))
print("[nftables] router defaults use fw4/nftables")
PY
