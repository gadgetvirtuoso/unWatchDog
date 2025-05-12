# unWatchDog

**unWatchDog** is a terminal-based macOS toolkit that diagnoses, explains, and fixes broken Apple Watch unlock (Auto Unlock) functionality — for both macOS login and third-party apps like 1Password. It interprets real system logs, walks you through recovery, and offers tools to reset, diagnose, and debug Apple Watch unlock failures.

---

### 🔧 Features (v1.1.1)

- 🕵️ Detects Auto Unlock failures and interprets system logs in plain English  
- 📂 Verifies trust file integrity (`ltk.plist`)  
- 📡 Diagnoses Bluetooth and AWDL issues affecting unlock  
- 🧩 Parses third-party app unlock failures using `LocalAuthentication` logs  
- 🧠 Translates known error codes (like `kLAErrorAuthenticationFailed`) into readable explanations  
- 🧪 Diagnostics submenu to choose individual tests  
- 🔄 Optional trust chain reset with safe loginwindow restart (logout warning included)  
- 🧙 Guided repair wizard for users stuck in “reboot didn’t help” mode  
- 📦 Packages logs for ChatGPT/support with AI-readable instructions  
- ✅ Works on Apple Silicon and Intel  
- 🚫 No dependencies — just a `.command` file

---

### 🖥️ Installation

git clone https://github.com/GadgetVirtuoso/unWatchDog.git  
cd unWatchDog  
chmod +x watch_unlock_tool.command  
open -a Terminal ./watch_unlock_tool.command

Or just double-click the file in Finder.

---

### 📋 Menu Options

**1️⃣ Check AutoUnlock state**  
Reads recent loginwindow logs to determine current unlock state:  
- 0 = Unknown (after boot or undefined)  
- 1 = Active (Watch unlock is enabled and working)  
- 2 = Inactive (password required before Watch will work again)

**2️⃣ Run diagnostics (choose log types)**  
Launches a submenu where you can:  
- 📄 View AutoUnlock logs  
- 📡 View Bluetooth + AWDL logs  
- 📂 Check trust files (e.g. `ltk.plist`)  
- 🔍 Analyze 3rd-party unlock issues (1Password, etc.) using `LocalAuthentication` logs  
- 🧪 Run all diagnostics  
- ↩️ Return to main menu

**3️⃣ Reset trust chain and services**  
- 🧨 Deletes trust files in `~/Library/Sharing/AutoUnlock`  
- 🔄 Restarts `sharingd` and `bluetoothd`  
- ⚠️ Optionally restarts `loginwindow` (logs you out — you're warned first)  
- ⚙️ Opens System Settings > Touch ID for manual re-enabling

**4️⃣ Fix missing trust chain (manual steps)**  
Prompts you through options like:  
- 🔁 Toggle unlock off/on  
- ☁️ Sign out and back into iCloud  
- ⌚ Unpair and re-pair Apple Watch

**5️⃣ Repair wizard (guided recovery)**  
Walks you through trust repair steps with prompts and checks along the way. Ideal if reboot + toggle didn’t work.

**6️⃣ Package logs for ChatGPT or support**  
- 🪵 AutoUnlock logs  
- 📡 Bluetooth + AWDL logs  
- 🔍 LocalAuthentication logs (3rd-party apps)  
- 📂 Trust file listing  
- 📄 A text file with instructions and AI prompt  
Lets you choose: Desktop, Downloads, Documents, or a custom path.

**7️⃣ Quit**  
👋 Exits the script without doing anything.

---

### 📄 License

MIT License — fork it, use it, break it, fix it.

---

### 🤝 Contributions

Pull requests welcome — especially for:  
- 🧠 Improved log analysis  
- 🎯 MDM or enterprise support  
- 🖥️ GUI versions or AppleScript wrappers  
- 🧪 Deeper Watch-to-Mac trust diagnostics

---

### 🚫 Disclaimer

This project is not affiliated with Apple. It reads system logs and may delete trust files to restore unlock functionality. Use responsibly. Always re-enable Apple Watch unlock manually in System Settings after running repairs.