#!/bin/bash
# DIY script part 1 (Before Update feeds)

# Enable helloworld if commented out, otherwise add it
sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
grep -q 'helloworld' feeds.conf.default || sed -i '$a src-git helloworld https://github.com/fw876/helloworld.git' feeds.conf.default

# Add passwall (remove first to avoid duplicates)
grep -q 'passwall_packages' feeds.conf.default || sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git' feeds.conf.default
grep -q 'src-git passwall ' feeds.conf.default || sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall.git' feeds.conf.default

# Add istore
grep -q 'istore' feeds.conf.default || sed -i '$a src-git istore https://github.com/linkease/istore;main' feeds.conf.default
