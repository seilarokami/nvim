-- Folder action for ~/Documents/Personal/IDs & Licenses
-- Applies the "Reference" Finder tag to anything dropped in
on adding folder items to theFolder after receiving theItems
    tell application "Finder"
        repeat with theItem in theItems
            try
                set tag names of (theItem as alias) to {"Reference"}
            end try
        end repeat
    end tell
end adding folder items to
