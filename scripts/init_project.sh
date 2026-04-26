#!/bin/bash
# init_project.sh
# Initializes a git repo and README in a new Dev project folder.
# Called by a macOS Shortcuts folder action on ~/Documents/Dev/Projects/.
# Usage: init_project.sh "/path/to/new/project-folder"

FOLDER="$1"

# Validate input
if [ -z "$FOLDER" ] || [ ! -d "$FOLDER" ]; then
  echo "Error: folder not found — $FOLDER"
  exit 1
fi

# Skip if already a git repo
if [ -d "$FOLDER/.git" ]; then
  echo "Already a git repo, skipping: $FOLDER"
  exit 0
fi

project_name=$(basename "$FOLDER")

cd "$FOLDER" || exit 1

# Init git
git init -q

# Write README
cat > README.md << EOF
# $project_name

Created: $(date +%Y-%m-%d)

## What is this?

## Notes

EOF

# Initial commit
git add README.md
git commit -q -m "Initial commit"

echo "Initialized: $project_name"
