#!/bin/zsh
# finalize.sh — Run this once in your terminal to finish the Mac setup.
# Does: folder action compile+attach, launchd agent load, Desktop cleanup.

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       Finalizing Mac Setup           ║"
echo "╚══════════════════════════════════════╝"
echo ""

SCRIPTS="$HOME/Scripts"
FOLDER_ACTIONS="$HOME/Library/Scripts/Folder Action Scripts"
LAUNCHAGENTS="$HOME/Library/LaunchAgents"

# ── 1. Compile AppleScript folder actions ─────────────────────────────────
echo "▸ Compiling folder actions..."
mkdir -p "$FOLDER_ACTIONS"

for script in "$SCRIPTS/applescript/"*.applescript; do
    name=$(basename "$script" .applescript)
    osacompile -o "$FOLDER_ACTIONS/$name.scpt" "$script" && echo "  ✓ $name" || echo "  ✗ $name failed"
done
echo ""

# ── 2. Attach folder actions to folders ───────────────────────────────────
echo "▸ Attaching folder actions..."

attach() {
    local folder="$1"
    local script="$2"
    local scpt="$FOLDER_ACTIONS/$script.scpt"
    osascript <<EOF
tell application "System Events"
    set folder actions enabled to true
    try
        make new folder action at end of folder actions with properties {name:"$folder", path:"$folder"}
        tell last folder action
            make new script at end of scripts with properties {name:"$script", path:"$scpt"}
        end tell
        log "Attached $script"
    on error e
        log "Note: " & e
    end try
end tell
EOF
    echo "  ✓ $script → $folder"
}

attach "$HOME/Downloads"                           "sort_downloads"
attach "$HOME/Desktop"                             "rename_screenshot"
attach "$HOME/Documents/Dev/Projects"              "init_project"
attach "$HOME/Documents/Personal/IDs & Licenses"  "tag_reference"
echo ""

# ── 3. Load launchd weekly reminder ───────────────────────────────────────
echo "▸ Loading weekly Downloads reminder..."
launchctl load "$LAUNCHAGENTS/com.kaiotosto.downloads-check.plist" 2>/dev/null \
    && echo "  ✓ Loaded (fires Sundays at 7pm)" \
    || echo "  ✓ Already loaded"
echo ""

# ── 4. Move Desktop screenshots ───────────────────────────────────────────
echo "▸ Moving Desktop screenshots..."
mkdir -p "$HOME/Pictures/Screenshots"
count=0
for f in "$HOME/Desktop/Screenshot"*.png "$HOME/Desktop/Screenshot"*.jpg; do
    [ -f "$f" ] || continue
    mv "$f" "$HOME/Pictures/Screenshots/" && count=$((count+1))
done
echo "  ✓ Moved $count screenshot(s)"
echo ""

# ── 5. Done ───────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════╗"
echo "║       Finalized!                     ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Three last clicks:"
echo "  1. Finder → Settings (⌘,) → Tags → rename the 6 colors:"
echo "     Red=Active  Orange=Inbox  Blue=Reference"
echo "     Purple=Linked  Green=Export  Gray=Archive"
echo ""
echo "  2. Right-click Desktop → Use Stacks"
echo ""
echo "  3. Drag to Finder sidebar: ~/Documents/Dev  ~/Documents/Music  ~/Gaming"
echo ""
echo "  Then follow ~/Scripts/SHORTCUTS_SETUP.md for the automations."
echo ""
