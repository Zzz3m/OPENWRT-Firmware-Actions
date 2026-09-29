#!/bin/bash
# DIY script part 2 (After Update feeds)

# Modify default IP
sed -i 's/192.168.1.1/10.0.10.111/g' package/base-files/files/bin/config_generate
