-- Folder action for ~/Desktop
-- Fires when files are added, renames and moves anything starting with "Screenshot"
on adding folder items to theFolder after receiving theItems
    repeat with theItem in theItems
        try
            set theName to name of (theItem as alias)
            if theName starts with "Screenshot" then
                set thePath to POSIX path of (theItem as alias)
                do shell script "/bin/bash $HOME/Scripts/rename_screenshot.sh " & quoted form of thePath
            end if
        end try
    end repeat
end adding folder items to
