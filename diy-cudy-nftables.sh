#!/bin/bash
# Cudy TR3000: 把 DEFAULT_PACKAGES.router 中硬编码的 iptables 默认包
# 换成 nftables(fw4) 对应包。
#
# 只改 .config 是不够的：include/target.mk 的默认包集合会在 make defconfig
# 阶段把 iptables / iptables-mod-tproxy / iptables-mod-extra / ipset /
# ip6tables / libip6tc / kmod-ipt-nat6 / kmod-ipt-raw 重新拉回固件。
# 本脚本由 build-cudy-tr3000.yml 单独调用，不影响其它机型的 workflow。
set -e

SRC="${GITHUB_WORKSPACE}/openwrt/include/target.mk"
echo "[nftables] patching $SRC"

python3 - "$SRC" <<'PY'
import pathlib
import re
import sys

p = pathlib.Path(sys.argv[1])
lines = p.read_text().splitlines(keepends=True)

start = next(
    (i for i, l in enumerate(lines) if l.startswith("DEFAULT_PACKAGES.router:=")),
    None,
)
if start is None:
    raise SystemExit("ERROR: DEFAULT_PACKAGES.router not found")

end = start
while end < len(lines) and lines[end].rstrip("\r\n").rstrip().endswith("\\"):
    end += 1
if end >= len(lines):
    raise SystemExit("ERROR: unterminated DEFAULT_PACKAGES.router block")

block = "".join(lines[start:end + 1])

# 左边是 iptables 栈默认包，右边是 nftables 对应实现。
replacements = [
    ("iptables-mod-tproxy ", "kmod-nft-tproxy "),
    ("iptables-mod-extra ",  ""),
    ("kmod-ipt-nat6 ",       "kmod-nft-nat6 "),
    ("kmod-ipt-raw ",        "kmod-nft-offload "),
    ("ipset ",               ""),
    ("ip6tables ",           ""),
    ("libip6tc ",            ""),
    ("iptables ",            ""),
]
for old, new in replacements:
    block = block.replace(old, new)

# 防火墙主包必须成对：firewall4 + nftables-json
if "firewall4" not in block:
    block = block.replace("dnsmasq-full ", "dnsmasq-full firewall4 ", 1)
if "nftables-json" not in block:
    block = block.replace("firewall4 ", "firewall4 nftables-json ", 1)

left = re.findall(r"\b(?:iptables|ip6tables|iptables-mod-\S+|ipset|libip6tc|kmod-ipt-\S+)\b", block)
if left:
    raise SystemExit("ERROR: 默认包中仍残留 iptables 组件: %s" % left)

p.write_text("".join(lines[:start]) + block + "".join(lines[end + 1:]))
print("[nftables] 默认包集合已切换为 fw4/nftables")
PY

grep -A3 'DEFAULT_PACKAGES.router' "$SRC" | head -5
