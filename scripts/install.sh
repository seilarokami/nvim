#!/bin/zsh
# install.sh — Full Mac setup in one shot.
# Run once: chmod +x ~/Scripts/install.sh && ~/Scripts/install.sh

set -e
SCRIPTS="$HOME/Scripts"
LAUNCHAGENTS="$HOME/Library/LaunchAgents"
FOLDER_ACTIONS="$HOME/Library/Scripts/Folder Action Scripts"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       Mac Setup — Starting           ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. File reorganization ────────────────────────────────────────────────
echo "▸ Reorganizing files..."
/bin/bash "$SCRIPTS/run_once_reorganize.sh"
echo ""

# ── 2. Make all scripts executable ───────────────────────────────────────
echo "▸ Making scripts executable..."
chmod +x "$SCRIPTS"/*.sh
echo "  Done."
echo ""

# ── 3. Fix fastfetch / .zshrc path ───────────────────────────────────────
echo "▸ Updating fastfetch config path in .zshrc..."
if grep -q "Documents/mew_ascii.txt" "$HOME/.zshrc"; then
    sed -i '' 's|~/Documents/mew_ascii.txt|~/.config/fastfetch/mew_ascii.txt|g' "$HOME/.zshrc"
    echo "  Updated: ~/Documents/mew_ascii.txt → ~/.config/fastfetch/mew_ascii.txt"
else
    echo "  Already up to date."
fi
echo ""

# ── 4. Compile + install AppleScript folder actions ──────────────────────
echo "▸ Compiling folder action scripts..."
mkdir -p "$FOLDER_ACTIONS"

for script in "$SCRIPTS/applescript/"*.applescript; do
    name=$(basename "$script" .applescript)
    dest="$FOLDER_ACTIONS/$name.scpt"
    osacompile -o "$dest" "$script"
    echo "  Compiled: $name.scpt"
done
echo ""

# ── 5. Attach folder actions ─────────────────────────────────────────────
echo "▸ Attaching folder actions..."

attach_folder_action() {
    local folder_path="$1"
    local script_name="$2"
    local script_path="$FOLDER_ACTIONS/$script_name.scpt"

    # Enable folder actions globally + attach this script to this folder
    osascript <<EOF
tell application "System Events"
    set folder actions enabled to true
    set fa_path to POSIX file "$folder_path" as text
    set script_path to POSIX file "$script_path" as text
    -- Remove any existing action for this folder first
    try
        delete (folder actions whose name is fa_path)
    end try
    make new folder action at end of folder actions with properties {name:fa_path, path:"$folder_path"}
    tell last folder action
        make new script at end of scripts with properties {name:"$script_name", path:"$script_path"}
    end tell
end tell
EOF
    echo "  Attached $script_name → $folder_path"
}

attach_folder_action "$HOME/Downloads"                             "sort_downloads"
attach_folder_action "$HOME/Desktop"                               "rename_screenshot"
attach_folder_action "$HOME/Documents/Dev/Projects"                "init_project"
attach_folder_action "$HOME/Documents/Personal/IDs & Licenses"    "tag_reference"
echo ""

# ── 6. Install launchd scheduled task (weekly Downloads check) ───────────
echo "▸ Installing weekly Downloads reminder..."
mkdir -p "$LAUNCHAGENTS"
cp "$SCRIPTS/com.kaiotosto.downloads-check.plist" "$LAUNCHAGENTS/"
launchctl load "$LAUNCHAGENTS/com.kaiotosto.downloads-check.plist" 2>/dev/null || true
echo "  Loaded: com.kaiotosto.downloads-check (fires Sundays at 7pm)"
echo ""

# ── 7. Done ──────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════╗"
echo "║       All done! 🎉                   ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Three small things to do manually (each ~30 seconds):"
echo ""
echo "  1. Rename Finder tags:"
echo "     Finder → Settings (⌘,) → Tags"
echo "     Red=Active  Orange=Inbox  Blue=Reference"
echo "     Purple=Linked  Green=Export  Gray=Archive"
echo ""
echo "  2. Enable Desktop Stacks:"
echo "     Right-click Desktop → Use Stacks"
echo ""
echo "  3. Add key folders to Finder sidebar:"
echo "     Drag these to Favorites in any Finder window:"
echo "     ~/Documents/Dev    ~/Documents/Music    ~/Gaming"
echo ""
echo "  Smart Folder setup is in ~/Scripts/SHORTCUTS_SETUP.md"
echo "  (Finder → File → New Smart Folder for each one)"
echo ""
echo "  Restart your terminal to see the new fastfetch path."
echo ""
