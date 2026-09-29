#!/bin/bash
# DIY script part 1 (Before Update feeds)

# Enable helloworld if commented out, otherwise add it
sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
grep -q 'helloworld' feeds.conf.default || sed -i '$a src-git helloworld https://github.com/fw876/helloworld.git' feeds.conf.default
