#!/bin/bash
# DIY script part 1 (Before Update feeds)

# binutils-2.42 host 编译时 musl sysroot 头文件路径被加入 -I，导致 readelf.c
# 找不到 off64_t。在 Makefile 末尾追加 HOST_CFLAGS，GNU make += 任意位置有效。
echo '' >> toolchain/binutils/Makefile
echo 'HOST_CFLAGS += -D_LARGEFILE64_SOURCE=1' >> toolchain/binutils/Makefile
