#!/bin/bash
set -euo pipefail
config="${1:?Usage: validate-fw4.sh <generated .config>}"
for package in firewall4 nftables-json dnsmasq_full_nftset luci-app-ssr-plus_Nftables_Transparent_Proxy; do
  if ! grep -qx "CONFIG_PACKAGE_${package}=y" "$config"; then
    echo "::error::Required fw4 option missing: $package" >&2
    exit 1
  fi
done
if grep -E '^CONFIG_PACKAGE_(firewall|iptables[^=]*|ip6tables[^=]*|ipset|libip[46]tc|libipset|libiptext6?|libxtables|kmod-ipt[^=]*|kmod-ip6tables[^=]*|kmod-nf-ipt6?|dnsmasq_full_ipset|luci-app-ssr-plus_Iptables_Transparent_Proxy)=[ym]$' "$config"; then
  echo '::error::Legacy firewall dependencies remain in the generated config' >&2
  exit 1
fi
