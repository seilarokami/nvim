#!/bin/bash
# check_downloads.sh
# Counts files in ~/Downloads older than 7 days and sends a macOS notification.
# Run via a weekly scheduled Shortcut (every Sunday).

DOWNLOADS="$HOME/Downloads"
DAYS=7

# Count files (not folders, not hidden) older than N days
count=$(find "$DOWNLOADS" -maxdepth 1 -type f -not -name ".*" -mtime +"$DAYS" 2>/dev/null | wc -l | tr -d ' ')

if [ "$count" -gt 0 ]; then
  osascript -e "display notification \"$count file(s) in Downloads are older than $DAYS days. Time for a quick clean.\" with title \"Downloads Reminder\" subtitle \"Weekly cleanup\" sound name \"Glass\""
else
  osascript -e "display notification \"Downloads is clear — nothing older than $DAYS days.\" with title \"Downloads Reminder\" sound name \"Glass\""
fi
