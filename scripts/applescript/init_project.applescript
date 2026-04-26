-- Folder action for ~/Documents/Dev/Projects
-- Fires when a new folder is added, runs git init + README creation
on adding folder items to theFolder after receiving theItems
    repeat with theItem in theItems
        try
            -- Only act on folders, not files
            set theAlias to theItem as alias
            set theInfo to info for theAlias
            if folder of theInfo is true then
                set thePath to POSIX path of theAlias
                do shell script "/bin/bash $HOME/Scripts/init_project.sh " & quoted form of thePath
                display notification "Git repo initialized: " & name of theAlias with title "Dev Projects"
            end if
        end try
    end repeat
end adding folder items to
