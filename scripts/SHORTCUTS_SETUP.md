# Mac Automation Setup Guide
# macOS Tahoe — corrected instructions

All scripts live in `~/Scripts/`. Run this in Terminal before anything else:

```zsh
chmod +x ~/Scripts/*.sh
```

---

## How to create any automation in macOS Tahoe

1. Open the **Shortcuts** app (Cmd+Space → "Shortcuts")
2. In the **left sidebar**, click **Automation**
3. Click **+** in the top-right corner to create a new automation
4. Follow the specific steps for each automation below

---

## 1. Downloads Sorter

**Trigger:** File added to ~/Downloads  
**Script:** `sort_downloads.sh`

1. Shortcuts → Automation → **+**
2. Choose trigger: **Folder** → select **~/Downloads** → **Item Added**
3. Select **Run Immediately**, uncheck **Notify When Run** → click Done
4. You'll see a blank shortcut with **"Receive Folder Change Summary As Input"** as step 1 — leave it
5. Click **+** to add an action → search for **Run Shell Script**
6. Set Shell: `/bin/bash`, Input: **Nothing**
7. Paste as the script body:
   ```bash
   ~/Scripts/sort_downloads.sh
   ```
8. Save (Cmd+S) → name it **Sort Downloads**

---

## 2. Screenshot Cleaner

**Trigger:** File added to ~/Desktop starting with "Screenshot"  
**Script:** `rename_screenshot.sh`

1. Shortcuts → Automation → **+**
2. Trigger: **Folder** → select **~/Desktop** → **Item Added**
3. **Run Immediately**, no notification → Done
4. Add action: **Filter Files**
   - Filter: **Name begins with "Screenshot"**
   - From: **Shortcut Input**
5. Add action: **Repeat with Each**
   - Set input to the **filtered files** from the previous step
6. Inside the repeat, add: **Run Shell Script**
   - Shell: `/bin/bash`, Input: **Repeat Item** (from the variable picker)
   - Script body:
     ```bash
     ~/Scripts/rename_screenshot.sh "$1"
     ```
7. Save → name it **Clean Screenshot**

---

## 3. Git Init for New Projects

**Trigger:** Folder added to ~/Documents/Dev/Projects  
**Script:** `init_project.sh`

1. Shortcuts → Automation → **+**
2. Trigger: **Folder** → select **~/Documents/Dev/Projects** → **Item Added**
3. **Run Immediately**, no notification → Done
4. Add action: **Filter Files**
   - Filter: **Kind is Folder**
   - From: **Shortcut Input**
5. Add action: **Repeat with Each** → input: filtered results
6. Inside repeat, add: **Run Shell Script**
   - Shell: `/bin/bash`, Input: **Repeat Item**
   - Script:
     ```bash
     ~/Scripts/init_project.sh "$1"
     ```
7. Save → name it **Init Project**

> Make sure git is installed: run `git --version` in Terminal.
> If not, macOS will offer to install Xcode Command Line Tools.

---

## 4. Auto-tag Reference Files

**Trigger:** File added to ~/Documents/Personal/IDs & Licenses  
**No script needed — uses a native Shortcuts action**

1. Shortcuts → Automation → **+**
2. Trigger: **Folder** → select **~/Documents/Personal/IDs & Licenses** → **Item Added**
3. **Run Immediately**, no notification → Done
4. Add action: **Add Tags**
   - Tags: type **Reference**
   - File: **Shortcut Input**
5. Save → name it **Tag Reference**

---

## 5. Weekly Downloads Cleanup Nudge

**Trigger:** Every Sunday at 7pm  
**Script:** `check_downloads.sh`

> Note: The launchd agent installed by `install.sh` already handles this automatically.
> Only set this up in Shortcuts if you want a duplicate reminder or if launchd isn't working.

1. Shortcuts → Automation → **+**
2. Trigger: **Time of Day**
   - Time: **7:00 PM**
   - Days: **Sunday**
3. **Run Immediately** → Done
4. Add action: **Run Shell Script**
   - Shell: `/bin/bash`, Input: **Nothing**
   - Script:
     ```bash
     ~/Scripts/check_downloads.sh
     ```
5. Save → name it **Downloads Check**

---

## Tag Color Reference

Set these up in **Finder → Settings (⌘,) → Tags** — just rename the existing colors:

| Color  | Rename to | Meaning                                |
|--------|-----------|----------------------------------------|
| Red    | Active    | Currently working on this              |
| Orange | Inbox     | Needs to be processed or filed         |
| Blue   | Reference | Important permanent doc, never archive |
| Purple | Linked    | Has a corresponding Obsidian note      |
| Green  | Export    | Final output / deliverable             |
| Gray   | Archive   | Done and inactive                      |

---

## Smart Folders

In Finder: **File → New Smart Folder** → click **+** to add criteria → **Save** to sidebar.

| Name                        | Criteria                                                        |
|-----------------------------|-----------------------------------------------------------------|
| Active right now            | Tags includes "Active"                                          |
| Needs processing            | Tags includes "Inbox"                                           |
| In Obsidian                 | Tags includes "Linked"                                          |
| Important docs              | Tags includes "Reference"                                       |
| Active but not in Obsidian  | Tags includes "Active" AND Tags does not include "Linked"       |
| Large files                 | File Size > 50 MB AND Tags does not include "Archive"           |

---

## Remaining manual steps (each ~30 seconds)

1. Rename Finder tags (above)
2. Right-click Desktop → **Use Stacks**
3. Drag `~/Documents/Dev`, `~/Documents/Music`, `~/Gaming` to Finder sidebar Favorites
