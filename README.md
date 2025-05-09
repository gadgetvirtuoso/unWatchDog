# unWatchDog

**unWatchDog** is a terminal-based macOS toolkit that diagnoses, explains, and fixes broken Apple Watch unlock (Auto Unlock) functionality. No more reboot roulette.

### 🔧 Features

- Detects Auto Unlock failures and explains the cause  
- Interprets system logs with human-readable analysis  
- Diagnoses missing or broken trust chain (`ltk.plist`, `watch-companion-mapping.plist`)  
- Checks Bluetooth and AWDL health  
- Optionally resets trust-related files and restarts services  
- Step-by-step repair wizard for persistent unlock failures  
- Verbose/non-verbose terminal mode toggle  
- Packages logs for upload and review (e.g., ChatGPT, Apple Support)  
- User can choose where logs are saved: Desktop, Downloads, Documents, or custom path  
- Works on Apple Silicon and Intel Macs (macOS 12+ recommended)

### 🖥️ Example Usage

```bash
./watch_unlock_tool.command
```

On launch, you’ll be prompted:

```bash
📝 Show logs and raw output in terminal? (y/n):
```

Then choose from this menu:

```
1. Check AutoUnlock state (with analysis)  
2. Run diagnostics (trust + Bluetooth + state)  
3. Reset trust chain and services  
4. Fix missing watch-companion trust chain  
5. Repair wizard (step-by-step user guidance)  
6. Package logs for review  
7. Quit  
```

### 📦 Installation

Clone this repo and run the script:

```bash
git clone https://github.com/GadgetVirtuoso/unWatchDog.git
cd unWatchDog
chmod +x watch_unlock_tool.command
open -a Terminal ./watch_unlock_tool.command
```

Or move it to `/Applications` and run it like a native `.command` app.

### 📄 License

MIT License — use freely, modify, and share.

### 🤝 Contributions

Pull requests welcome. If you've improved logging, error detection, added verbose parsing, or made it MDM-friendly, send it in.

### 🚫 Disclaimer

This project is unofficial and not affiliated with Apple. It works by interacting with public system logs and deleting user-local trust data. Use responsibly.
