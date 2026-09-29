#!/bin/bash
# DIY script part 1 (Before Update feeds)

# Add helloworld feed
sed -i '$a src-git helloworld https://github.com/fw876/helloworld.git' feeds.conf.default

# Add passwall
sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git' feeds.conf.default
sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall.git' feeds.conf.default

# Add istore
sed -i '$a src-git istore https://github.com/linkease/istore;main' feeds.conf.default
