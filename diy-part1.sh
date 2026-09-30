#!/bin/bash
# DIY script part 1 (Before Update feeds)

# 将 luci feed 改回默认分支，匹配旧版 config
sed -i 's|src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-25.12|src-git luci https://github.com/coolsnowwolf/luci.git|' feeds.conf.default
