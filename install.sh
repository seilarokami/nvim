#!/bin/zsh
# install.sh — Run once on a fresh Mac to get everything set up.
# Usage: git clone https://github.com/seilarokami/dotfiles ~/Documents/Dev/dotfiles
#        chmod +x ~/Documents/Dev/dotfiles/install.sh && ~/Documents/Dev/dotfiles/install.sh

set -e

DOTFILES="$HOME/Documents/Dev/dotfiles"
SCRIPTS="$DOTFILES/scripts"
LAUNCHAGENTS="$HOME/Library/LaunchAgents"
FOLDER_ACTIONS="$HOME/Library/Scripts/Folder Action Scripts"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       Dotfiles Setup — Starting      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 0. Folder structure ───────────────────────────────────────────────────
echo "▸ Creating folder structure..."
mkdir -p "$HOME/Documents/Dev"
mkdir -p "$HOME/Documents/Music"
mkdir -p "$HOME/Documents/Dev/Projects"
mkdir -p "$HOME/Documents/Personal/IDs & Licenses"
mkdir -p "$HOME/Unsorted"
mkdir -p "$HOME/Downloads"
echo "  Done."
echo ""

# ── 1. Clone dotfiles ─────────────────────────────────────────────────────
echo "▸ Cloning dotfiles..."
if [[ -d "$DOTFILES/.git" ]]; then
    echo "  Already exists at $DOTFILES — skipping clone."
else
    git clone https://github.com/seilarokami/dotfiles "$DOTFILES"
fi
echo ""

# ── 2. Homebrew ───────────────────────────────────────────────────────────
echo "▸ Installing Homebrew..."
if command -v brew &>/dev/null; then
    echo "  Already installed."
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
echo ""

# ── 3. CLI tools ──────────────────────────────────────────────────────────
echo "▸ Installing CLI tools..."
brew install \
    neovim \
    lsd \
    fastfetch \
    gh \
    uv \
    zsh-syntax-highlighting \
    powerlevel10k
echo ""

# ── 4. GUI apps ───────────────────────────────────────────────────────────
echo "▸ Installing GUI apps..."
brew install --cask ghostty linearmouse
echo ""

# ── 5. Symlinks ───────────────────────────────────────────────────────────
echo "▸ Creating symlinks..."

symlink() {
    local src="$1"
    local dst="$2"
    if [[ -L "$dst" ]]; then
        echo "  Already linked: $dst"
    elif [[ -e "$dst" ]]; then
        echo "  ⚠️  File exists (not a symlink), skipping: $dst"
    else
        ln -s "$src" "$dst"
        echo "  Linked: $(basename $dst) → $src"
    fi
}

# Shell
symlink "$DOTFILES/shell/.zshrc"    "$HOME/.zshrc"
symlink "$DOTFILES/shell/.zprofile" "$HOME/.zprofile"
symlink "$DOTFILES/shell/.p10k.zsh" "$HOME/.p10k.zsh"

# Git
symlink "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# .config dirs
mkdir -p "$HOME/.config"
symlink "$DOTFILES/nvim"        "$HOME/.config/nvim"
symlink "$DOTFILES/ghostty"     "$HOME/.config/ghostty"
symlink "$DOTFILES/envman"      "$HOME/.config/envman"
symlink "$DOTFILES/linearmouse" "$HOME/.config/linearmouse"
echo ""

# ── 6. fastfetch config ───────────────────────────────────────────────────
echo "▸ Setting up fastfetch config..."
mkdir -p "$HOME/.config/fastfetch"
if [[ ! -f "$HOME/.config/fastfetch/mew_ascii.txt" ]]; then
    cp "$DOTFILES/shell/mew_ascii.txt" "$HOME/.config/fastfetch/mew_ascii.txt" 2>/dev/null || true
fi
echo "  Done."
echo ""

# ── 7. AppleScript folder actions ─────────────────────────────────────────
echo "▸ Compiling AppleScript folder actions..."
mkdir -p "$FOLDER_ACTIONS"
for script in "$SCRIPTS/applescript/"*.applescript; do
    name=$(basename "$script" .applescript)
    dest="$FOLDER_ACTIONS/$name.scpt"
    osacompile -o "$dest" "$script"
    echo "  Compiled: $name.scpt"
done
echo ""

echo "▸ Attaching folder actions..."
attach_folder_action() {
    local folder_path="$1"
    local script_name="$2"
    local script_path="$FOLDER_ACTIONS/$script_name.scpt"
    osascript <<EOF
tell application "System Events"
    set folder actions enabled to true
    try
        delete (folder actions whose name is "$folder_path")
    end try
    make new folder action at end of folder actions with properties {name:"$folder_path", path:"$folder_path"}
    tell last folder action
        make new script at end of scripts with properties {name:"$script_name", path:"$script_path"}
    end tell
end tell
EOF
    echo "  Attached $script_name → $folder_path"
}

attach_folder_action "$HOME/Downloads"                          "sort_downloads"
attach_folder_action "$HOME/Desktop"                            "rename_screenshot"
attach_folder_action "$HOME/Documents/Dev/Projects"            "init_project"
attach_folder_action "$HOME/Documents/Personal/IDs & Licenses" "tag_reference"
echo ""

# ── 8. launchd: weekly Downloads check ───────────────────────────────────
echo "▸ Installing launchd job..."
mkdir -p "$LAUNCHAGENTS"
cp "$SCRIPTS/com.kaiotosto.downloads-check.plist" "$LAUNCHAGENTS/"
launchctl load "$LAUNCHAGENTS/com.kaiotosto.downloads-check.plist" 2>/dev/null || true
echo "  Loaded: com.kaiotosto.downloads-check (fires Sundays at 7pm)"
echo ""

# ── 9. Make scripts executable ────────────────────────────────────────────
echo "▸ Making scripts executable..."
chmod +x "$SCRIPTS"/*.sh
echo "  Done."
echo ""

# ── Done ──────────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════╗"
echo "║       Setup complete!                ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Three manual steps (~30 seconds each):"
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
echo "     Drag to Favorites: ~/Documents/Dev  ~/Documents/Music  ~/Gaming"
echo ""
echo "  Smart Folder setup: dotfiles/scripts/SHORTCUTS_SETUP.md"
echo ""
echo "  Restart terminal to apply shell config."
echo ""
