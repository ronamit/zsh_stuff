#!/bin/bash
# Clear Cursor cache on Linux/Ubuntu (equivalent of macOS cache clear)
# Close Cursor before running this script.

CURSOR_DIR="$HOME/.config/Cursor"

rm -rf "$CURSOR_DIR"/{Cache,CachedData,CachedExtensionVSIXs,GPUCache,Code\ Cache,Service\ Worker,DawnGraphiteCache,DawnWebGPUCache,logs,WebStorage} 2>/dev/null
rm -f "$CURSOR_DIR/User/globalStorage/state.vscdb"* 2>/dev/null
rm -rf "$CURSOR_DIR/User/workspaceStorage" 2>/dev/null
rm -rf "$CURSOR_DIR/User/History" 2>/dev/null

echo "Cursor cache cleared. You can restart Cursor."
