#!/bin/bash
# sort_downloads.sh
# Routes files in ~/Downloads to their proper homes by extension.
# Called by a macOS Shortcuts folder action on the Downloads folder.
# Safe: never overwrites existing files (adds a counter suffix if name conflicts).

DOWNLOADS="$HOME/Downloads"
INBOX="$HOME/Documents/Inbox"
PICS="$HOME/Pictures"
SCREENSHOTS="$HOME/Pictures/Screenshots"
ROMS="$HOME/Gaming/ROMs"
INSTALLERS="$HOME/Downloads/Installers"
BITWIG="$HOME/Documents/Music/Bitwig/Projects"

# Ensure destinations exist
mkdir -p "$INBOX" "$PICS" "$SCREENSHOTS" "$ROMS" "$INSTALLERS" "$BITWIG"

# Safe move: if destination file exists, append a counter
safe_move() {
  local src="$1"
  local dest_dir="$2"
  local name
  name=$(basename "$src")
  local base="${name%.*}"
  local ext="${name##*.}"
  local dest="$dest_dir/$name"
  local counter=1

  # If no extension (or same as base), handle gracefully
  [ "$base" = "$name" ] && ext=""

  while [ -e "$dest" ]; do
    if [ -n "$ext" ]; then
      dest="$dest_dir/${base}-${counter}.${ext}"
    else
      dest="$dest_dir/${name}-${counter}"
    fi
    counter=$((counter + 1))
  done

  mv "$src" "$dest"
  echo "Moved: $name → $dest"
}

# Process each file (not directories) in Downloads root
for file in "$DOWNLOADS"/*; do
  [ -f "$file" ] || continue

  name=$(basename "$file")
  ext="${name##*.}"
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  case "$ext_lower" in

    # Documents → Inbox (for manual review before filing)
    pdf|doc|docx|pages|txt|rtf|odt|xlsx|csv|pptx|key|numbers)
      safe_move "$file" "$INBOX"
      ;;

    # Images → Pictures (screenshots handled separately)
    png|jpg|jpeg|gif|webp|heic|tiff|bmp|svg)
      if [[ "$name" == Screenshot* ]]; then
        # Rename screenshot to clean format and move
        date_str=$(date +%Y-%m-%d)
        counter=1
        new_name="${date_str}-screenshot-${counter}.png"
        while [ -e "$SCREENSHOTS/$new_name" ]; do
          counter=$((counter + 1))
          new_name="${date_str}-screenshot-${counter}.png"
        done
        mv "$file" "$SCREENSHOTS/$new_name"
        echo "Screenshot renamed: $name → $new_name"
      else
        safe_move "$file" "$PICS"
      fi
      ;;

    # Disk images and installers → staging folder
    dmg|pkg|mpkg)
      safe_move "$file" "$INSTALLERS"
      ;;

    # Game ROMs → Gaming/ROMs
    nds|3ds|cia|gba|gb|gbc|gbs|nsp|xci|iso|nes|snes|z64|n64|gcm|wbfs)
      safe_move "$file" "$ROMS"
      ;;

    # Bitwig projects → Music/Bitwig/Projects
    bwproject|bwclip|bwpreset)
      safe_move "$file" "$BITWIG"
      ;;

    # Everything else stays in Downloads for manual review

  esac
done

echo "Sort complete: $(date)"
