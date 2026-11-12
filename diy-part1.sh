#!/bin/bash
# DIY script part 1 (Before Update feeds)
set -euo pipefail

# LEDE selects patches/<binutils version>, not the patches directory itself.
# Define the musl large-file API before any headers (and before the opening
# copyright comment), so readelf can use off64_t on affected host toolchains.
patch_dirs=(toolchain/binutils/patches/*/)
if [ ! -d "${patch_dirs[0]}" ]; then
  echo "No versioned binutils patch directories found; run from the LEDE root." >&2
  exit 1
fi
for patch_dir in "${patch_dirs[@]}"; do
  cat > "${patch_dir}100-largefile64-readelf.patch" <<'PATCH'
--- a/binutils/readelf.c
+++ b/binutils/readelf.c
@@ -0,0 +1 @@
+#define _LARGEFILE64_SOURCE 1
PATCH
done
