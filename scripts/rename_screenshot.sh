#!/bin/bash
# rename_screenshot.sh
# Renames and moves a single screenshot file passed as $1.
# Called by a macOS Shortcuts folder action on the Desktop.
# Usage: rename_screenshot.sh "/path/to/Screenshot 2026-04-24 at 14.32.11.png"

FILE="$1"
SCREENSHOTS="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOTS"

# Validate input
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Error: file not found — $FILE"
  exit 1
fi

# Only act on files that look like macOS screenshots
name=$(basename "$FILE")
if [[ "$name" != Screenshot* ]]; then
  echo "Not a screenshot, skipping: $name"
  exit 0
fi

# Build clean name: YYYY-MM-DD-screenshot-N.png
date_str=$(date +%Y-%m-%d)
counter=1
new_name="${date_str}-screenshot-${counter}.png"

while [ -e "$SCREENSHOTS/$new_name" ]; do
  counter=$((counter + 1))
  new_name="${date_str}-screenshot-${counter}.png"
done

mv "$FILE" "$SCREENSHOTS/$new_name"
echo "Renamed: $name → $new_name"
