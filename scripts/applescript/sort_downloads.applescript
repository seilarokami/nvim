-- Folder action for ~/Downloads
-- Fires when any file is added, calls sort_downloads.sh
on adding folder items to theFolder after receiving theItems
    try
        do shell script "/bin/bash $HOME/Scripts/sort_downloads.sh"
    on error errMsg
        display notification "Sort error: " & errMsg with title "Downloads Sorter"
    end try
end adding folder items to
