#!/bin/bash
# run_once_reorganize.sh
# ONE-TIME script to reorganize your Mac into the new structure.
# Run this ONCE from Terminal, then delete it.
#
# Usage:
#   chmod +x ~/Scripts/run_once_reorganize.sh
#   ~/Scripts/run_once_reorganize.sh
#
# What it moves:
#   - Personal PDFs (IDs, licenses, school records) → Documents/Personal/
#   - Desktop/repos/ → Documents/Dev/Projects/
#   - Desktop/odin/ → Documents/Dev/Learning/
#   - Desktop/temp/ (3DS data) → Gaming/3DS Backup/
#   - Downloads ROMs (.nds files) → Gaming/ROMs/
#   - Downloads Ren'Py games (folders) → Gaming/Games/
#
# What it does NOT touch:
#   - iCloud mirror folders (Documents - Kaio's MacBook Air, Desktop - Kaio's MacBook Air - 1)
#   - Bitwig projects (needs manual review before consolidating)
#   - Anything in ~/Library, ~/Music, ~/Movies, ~/Pictures (native Mac folders)

set -e  # stop on any error

echo ""
echo "=== Mac Reorganization ==="
echo "Starting at $(date)"
echo ""

# ── Personal IDs & Licenses ────────────────────────────────────────────────
echo "→ Moving personal IDs and licenses..."

move_if_exists() {
  local src="$1"
  local dest_dir="$2"
  if [ -e "$src" ]; then
    mv "$src" "$dest_dir/"
    echo "  Moved: $(basename "$src")"
  fi
}

move_if_exists ~/Documents/CNH.pdf                            ~/Documents/Personal/"IDs & Licenses"
move_if_exists ~/Documents/StudentID.pdf                      ~/Documents/Personal/"IDs & Licenses"
move_if_exists ~/Documents/USLicense.pdf                      ~/Documents/Personal/"IDs & Licenses"
move_if_exists ~/Documents/SKM_C30813010102230.pdf            ~/Documents/Personal/"IDs & Licenses"
move_if_exists ~/Documents/"Appointment real.pdf"             ~/Documents/Personal/"IDs & Licenses"

# ── School Records ─────────────────────────────────────────────────────────
echo "→ Moving school records..."

move_if_exists ~/Documents/"HISTÓRICO ESCOLAR 1 2.pdf"        ~/Documents/Personal/"School Records"

# ── Engineering / University files ────────────────────────────────────────
echo "→ Moving university / engineering files..."

move_if_exists ~/Documents/ENTREGA_FINAL_CAD.pdf              ~/Documents/University/Engineering
move_if_exists ~/Documents/ENTRGEA_FINAL_CAD_REAL.pdf         ~/Documents/University/Engineering
move_if_exists ~/Documents/ENTREGA_FINAL_CAD_REAL_REAL.pdf    ~/Documents/University/Engineering
move_if_exists ~/Documents/plot.log                           ~/Documents/University/Engineering

# ── Dev projects off Desktop ───────────────────────────────────────────────
echo "→ Moving dev projects from Desktop..."

if [ -d ~/Desktop/repos ]; then
  # Move each repo individually to avoid clobbering anything in Projects/
  for repo in ~/Desktop/repos/*/; do
    [ -d "$repo" ] || continue
    repo_name=$(basename "$repo")
    if [ -d ~/Documents/Dev/Projects/"$repo_name" ]; then
      echo "  WARNING: $repo_name already exists in Dev/Projects — skipping"
    else
      mv "$repo" ~/Documents/Dev/Projects/
      echo "  Moved repo: $repo_name"
    fi
  done
  # Remove the now-empty repos folder if empty
  rmdir ~/Desktop/repos 2>/dev/null && echo "  Removed empty Desktop/repos/"
fi

if [ -d ~/Desktop/odin ]; then
  mv ~/Desktop/odin ~/Documents/Dev/Learning/
  echo "  Moved: odin → Dev/Learning/"
fi

# ── Gaming files ───────────────────────────────────────────────────────────
echo "→ Moving gaming files..."

# 3DS backup from Desktop/temp
if [ -d ~/Desktop/temp ]; then
  mv ~/Desktop/temp ~/Gaming/"3DS Backup"/
  echo "  Moved: Desktop/temp → Gaming/3DS Backup/"
fi

# NDS ROMs from Downloads
for rom in ~/Downloads/*.nds ~/Downloads/*.3ds ~/Downloads/*.cia; do
  [ -f "$rom" ] || continue
  mv "$rom" ~/Gaming/ROMs/
  echo "  Moved ROM: $(basename "$rom")"
done

# Move NDS ROM folders (World Ends with You folder, etc.)
for romdir in ~/Downloads/"World Ends with You, The (USA)"; do
  [ -d "$romdir" ] || continue
  mv "$romdir" ~/Gaming/ROMs/
  echo "  Moved ROM folder: $(basename "$romdir")"
done

# Ren'Py game folders from Downloads → Gaming/Games
for gamedir in ~/Downloads/RavensQuest-1 ~/Downloads/WelcomeToErosland-0 ~/Downloads/WelcomeToErosland-0-2; do
  [ -d "$gamedir" ] || continue
  mv "$gamedir" ~/Gaming/Games/
  echo "  Moved game: $(basename "$gamedir")"
done

# ── Make scripts executable ────────────────────────────────────────────────
echo "→ Making scripts executable..."
chmod +x ~/Scripts/*.sh
echo "  Done"

# ── Summary ───────────────────────────────────────────────────────────────
echo ""
echo "=== Done! ==="
echo ""
echo "What's left to do manually:"
echo "  1. Open Finder → Settings → Tags → rename the 6 color tags"
echo "     (see SHORTCUTS_SETUP.md for the names)"
echo "  2. Set up the 5 Shortcuts automations"
echo "     (step-by-step in ~/Scripts/SHORTCUTS_SETUP.md)"
echo "  3. Right-click Desktop → Use Stacks"
echo "  4. Create Smart Folders in Finder → File → New Smart Folder"
echo "     (queries listed in SHORTCUTS_SETUP.md)"
echo "  5. Consolidate Bitwig projects when you're ready"
echo "     (check Documents/Bitwig Studio/ vs Documents - Kaio's MacBook Air/Bitwig Studio/)"
echo ""
echo "Completed at $(date)"
