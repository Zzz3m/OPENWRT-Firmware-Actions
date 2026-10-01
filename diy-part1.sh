#!/bin/bash
# DIY script part 1 (Before Update feeds)

# binutils-2.42 readelf.c fails when musl sysroot headers land in the host gcc
# include path — musl gates off64_t behind _LARGEFILE64_SOURCE. Use a zero-context
# patch (no surrounding lines) so it applies regardless of exact file content.
cat > toolchain/binutils/patches/100-largefile64-readelf.patch << 'EOF'
--- a/binutils/readelf.c
+++ b/binutils/readelf.c
@@ -1,0 +1,1 @@
+#define _LARGEFILE64_SOURCE 1
EOF
