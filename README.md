# unWatchDog

**unWatchDog** is a terminal-based macOS toolkit that diagnoses, explains, and fixes broken Apple Watch unlock (Auto Unlock) functionality. No more reboot roulette.

---

### 🔧 Features (v1.0.0)

- Detects Auto Unlock failures and interprets recent system logs
- Human-readable diagnosis of trust file or Bluetooth issues
- Verifies `ltk.plist` integrity (no longer checks deprecated files)
- Bluetooth + AWDL diagnostic scanner
- Optional trust file reset with loginwindow logout warning
- Diagnostics submenu for log-by-log troubleshooting
- Interactive repair wizard for Watch + iCloud fixes
- Log packaging with embedded ChatGPT/AI-friendly analysis prompt
- macOS native `.command` interface (works from Finder or Terminal)
- Compatible with Apple Silicon and Intel Macs

---

### 🖥️ Example Usage

Run from Terminal or double-click:
./watch_unlock_tool.command

---

### 📋 Menu Options Explained

**1️⃣ Check AutoUnlock state (with analysis)**  
Reads the last few lines from `system.log` and shows the current Auto Unlock state:  
- `State 0` = Unknown (post-boot or setup)  
- `State 1` = Active (Watch should unlock)  
- `State 2` = Inactive (password login required)  

💡 *Use this after a failed unlock to confirm whether your Mac even attempted it.*

---

**2️⃣ Run diagnostics (select log types)**  
Brings up a submenu with:
- AutoUnlock state log
- Bluetooth/AWDL logs
- Trust file presence (`ltk.plist`)
- Or run all 3

🧠 *Use this when you suspect deeper issues. You can check each layer without resetting anything.*

---

**3️⃣ Reset trust chain and services**  
Deletes `~/Library/Sharing/AutoUnlock/ltk.plist` and restarts:
- `sharingd`
- `bluetoothd`
- Optionally: `loginwindow` (which logs you out — you’ll be warned first)

🧨 *Use when Auto Unlock is stuck in State 2 and diagnostics show trust file corruption.*

---

**4️⃣ Fix missing trust chain (manual steps)**  
Explains how to manually trigger regeneration of trust files:
- Disable/re-enable unlock
- iCloud sign-out/in
- Unpair/re-pair Watch

🛠 *Use if resets haven’t worked and the trust chain still won’t regenerate.*

---

**5️⃣ Repair wizard (guided recovery)**  
Step-by-step menu guiding you through:
- Reboot + toggle unlock
- iCloud sign-out/in
- Unpair/re-pair Watch

👣 *Same ideas as Option 4, but broken into interactive steps.*

---

**6️⃣ Package logs for AI/ChatGPT review**  
Saves the following to a ZIP archive:
- AutoUnlock log
- Bluetooth/AWDL log
- Trust file listing
- A text file with instructions for ChatGPT or another LLM to analyze them

📦 *Perfect for sharing diagnostics with tech support, Apple, or ChatGPT.*

You'll be prompted to save the archive to Desktop, Downloads, Documents, or a custom path.

---

**7️⃣ Quit**  
Exits the tool with no changes made.

---

### 📦 Installation

Clone this repo and run the script:

git clone https://github.com/GadgetVirtuoso/unWatchDog.git  
cd unWatchDog  
chmod +x watch_unlock_tool.command  
open -a Terminal ./watch_unlock_tool.command

Or move the script to `/Applications` to run it like a native app.

---

### 📄 License

MIT License — use freely, modify, and share.

---

### 🤝 Contributions

Pull requests welcome. Especially improvements to log parsing, MDM use, or non-destructive fix options.

---

### 🚫 Disclaimer

This is an independent project and not affiliated with Apple. It interacts with system logs and user-local trust files. Use with understanding.