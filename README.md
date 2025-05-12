# unWatchDog

**unWatchDog** is a terminal-based macOS toolkit that diagnoses, explains, and fixes broken Apple Watch unlock (Auto Unlock) functionality. No more reboot roulette.

---

### 🔧 Features (v1.0.0)

- Detects Auto Unlock failures and interprets system logs in plain English
- Verifies `ltk.plist` trust file integrity
- Diagnoses Bluetooth/AWDL issues affecting unlock
- Adds support for analyzing 3rd-party Watch unlock failures (e.g. 1Password)
- Interactive diagnostics submenu for detailed log review
- Optional trust reset and loginwindow restart (with logout warning)
- Repair wizard to walk through iCloud/signout/re-pair fixes
- AI log packaging with prewritten analysis prompt (for ChatGPT etc)
- macOS native `.command` — no installs, no dependencies

---

### 🖥️ Usage

Run from Terminal or double-click:
./watch_unlock_tool.command

---

### 📋 Menu Options Explained

**1️⃣ Check AutoUnlock state**  
Check current unlock state from system logs:
- 0 = Unknown (post-boot/setup)
- 1 = Active
- 2 = Inactive (password required)

**2️⃣ Run diagnostics (choose log types)**  
Includes submenu:
- AutoUnlock logs
- Bluetooth/AWDL logs
- Trust file check
- **3rd-party app Apple Watch auth logs** (NEW)
- Full diagnostic scan
- Return to main menu

**3️⃣ Reset trust files and services**  
Removes trust files, restarts Bluetooth/sharingd, and optionally loginwindow (warns first).

**4️⃣ Manual fix instructions**  
Steps to regenerate trust chain manually:
- Re-enable unlock
- Sign out/in of iCloud
- Unpair/re-pair Watch

**5️⃣ Guided repair wizard**  
Walkthrough of common manual fixes with progress steps.

**6️⃣ Package logs for ChatGPT/support**  
Zips logs + trust file state + a prewritten prompt for AI tools. Saves to Desktop, Downloads, Documents, or custom path.

**7️⃣ Quit**  
Exit with no changes made.

---

### 📦 Install

git clone https://github.com/GadgetVirtuoso/unWatchDog.git  
cd unWatchDog  
chmod +x watch_unlock_tool.command  
open -a Terminal ./watch_unlock_tool.command

---

### 📄 License

MIT License — modify, fork, break, improve.

---

### 🤝 Contributions

Pull requests welcome. Especially if you're fixing log parsing, adding launch agent support, or improving 3rd-party app detection.

---

### 🚫 Disclaimer

This is not affiliated with Apple. It modifies local trust files and reads protected logs. Use with understanding.