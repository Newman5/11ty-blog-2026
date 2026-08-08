#!/bin/bash
# Compatibility wrapper: keep old entrypoint name while delegating to blog-menu.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/blog-menu.sh" "$@"
