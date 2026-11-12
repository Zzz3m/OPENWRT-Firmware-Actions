#!/bin/bash
# Compatibility entry point for the Cudy workflow.
set -euo pipefail
bash "$(dirname -- "$0")/diy-nftables.sh" "$@"
