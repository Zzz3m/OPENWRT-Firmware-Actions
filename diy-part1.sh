#!/bin/bash
# DIY script part 1 (Before Update feeds)

# binutils-2.42 readelf.c 在 musl 头文件路径加入时无法找到 off64_t。
# 在源码里定义 _LARGEFILE64_SOURCE 让 musl 暴露 LFS64 类型。
mkdir -p toolchain/binutils/patches
cat > toolchain/binutils/patches/001-fix-off64_t-musl.patch << 'PATCH'
--- a/binutils/readelf.c
+++ b/binutils/readelf.c
@@ -38,6 +38,10 @@
    along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

+#ifndef _LARGEFILE64_SOURCE
+#define _LARGEFILE64_SOURCE 1
+#endif
+
 #include "sysdep.h"
PATCH
