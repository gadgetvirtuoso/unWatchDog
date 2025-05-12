#!/bin/bash

AUTO_UNLOCK_DIR="$HOME/Library/Sharing/AutoUnlock"
NEEDED_FILES=("ltk.plist")

read -rp "📝 Show logs and raw output in terminal? (y/n): " verbose_choice
if [[ "$verbose_choice" =~ ^[Yy]$ ]]; then VERBOSE=true; else VERBOSE=false; fi

while true; do
  echo ""
  echo "🧭 Apple Watch Unlock Toolkit"
  echo "1️⃣  Check AutoUnlock state (with analysis)"
  echo "2️⃣  Run diagnostics (select log types)"
  echo "3️⃣  Reset trust chain and services"
  echo "4️⃣  Fix missing trust chain (manual steps)"
  echo "5️⃣  Repair wizard (guided recovery)"
  echo "6️⃣  Package logs for AI/ChatGPT review"
  echo "7️⃣  Quit"
  read -rp "Choose an option [1-7]: " choice
  echo ""

  case "$choice" in
    1)
      echo "🔍 Checking recent AutoUnlock state logs..."
      sleep 1
      log_output=$(log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d 2>/dev/null | tail -n 20)
      [ "$VERBOSE" = true ] && echo "$log_output"
      state_line=$(echo "$log_output" | grep "AutoUnlock state:" | tail -n 1)
      state=$(echo "$state_line" | grep -o "AutoUnlock state:[0-9]" | cut -d: -f2)
      case "$state" in
        0) echo "🟡 AutoUnlock state: 0 (Unknown)" ;;
        1) echo "🟢 AutoUnlock state: 1 (Active)" ;;
        2) echo "🔴 AutoUnlock state: 2 (Inactive — password required)" ;;
        *) echo "❓ AutoUnlock state unknown or not found" ;;
      esac
      ;;

    2)
      while true; do
        echo ""
        echo "🧪 Diagnostics Menu"
        echo "1. AutoUnlock state logs"
        echo "2. Bluetooth + AWDL logs"
        echo "3. Trust file check"
        echo "4. 3rd-party app unlock logs"
        echo "5. Run all diagnostics"
        echo "6. Return to main menu"
        read -rp "Select an option [1-6]: " log_choice
        echo ""

        case "$log_choice" in
          1)
            echo "🔍 AutoUnlock state logs:"
            log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d 2>/dev/null | tail -n 20
            ;;
          2)
            echo "📡 Bluetooth + AWDL logs:"
            log show --predicate 'eventMessage CONTAINS "bluetoothd" OR eventMessage CONTAINS "AWDL"' --style syslog --last 1d 2>/dev/null | tail -n 50
            ;;
          3)
            echo "📂 Trust file check in $AUTO_UNLOCK_DIR:"
            for file in "${NEEDED_FILES[@]}"; do
              if [ -f "$AUTO_UNLOCK_DIR/$file" ]; then
                echo "✅ Found: $file"
              else
                echo "❌ Missing: $file"
              fi
            done
            ;;
          4)
            echo "🔍 Searching for 3rd-party app Apple Watch auth logs..."
            log show --predicate 'eventMessage CONTAINS "LocalAuthentication" OR eventMessage CONTAINS "Apple Watch"' --style syslog --last 1d 2>/dev/null | grep -Ei "Watch|Auth|LAContext|kLAError" | tail -n 30
            ;;
          5)
            echo "⏳ Running all diagnostics..."
            sleep 1
            echo "📂 Trust files:"
            for file in "${NEEDED_FILES[@]}"; do
              if [ -f "$AUTO_UNLOCK_DIR/$file" ]; then
                echo "✅ Found: $file"
              else
                echo "❌ Missing: $file"
              fi
            done
            echo ""
            echo "📡 Bluetooth logs:"
            log show --predicate 'eventMessage CONTAINS "bluetoothd" OR eventMessage CONTAINS "AWDL"' --style syslog --last 1d 2>/dev/null | tail -n 50
            echo ""
            echo "🔍 AutoUnlock state:"
            log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d 2>/dev/null | tail -n 20
            echo ""
            echo "🔐 3rd-party app Watch unlock logs:"
            log show --predicate 'eventMessage CONTAINS "LocalAuthentication" OR eventMessage CONTAINS "Apple Watch"' --style syslog --last 1d 2>/dev/null | grep -Ei "Watch|Auth|LAContext|kLAError" | tail -n 30
            ;;
          6)
            break
            ;;
          *)
            echo "❌ Invalid option."
            ;;
        esac
      done
      ;;

    3)
      echo "🧼 Resetting trust files and services..."
      rm -rf "$AUTO_UNLOCK_DIR"/*
      sudo pkill sharingd
      sudo pkill bluetoothd

      echo ""
      echo "⚠️ Restarting loginwindow will log you out immediately!"
      read -rp "Skip restarting loginwindow? (y/n): " skip_lw
      if [[ "$skip_lw" =~ ^[Nn]$ ]]; then
        echo "💡 Nudging loginwindow..."
        launchctl kickstart -k gui/$(id -u)/com.apple.loginwindow
      else
        echo "🚫 Skipped loginwindow restart."
      fi

      echo "⚙️ Opening Touch ID settings..."
      open "x-apple.systempreferences:com.apple.TouchID-Settings.extension"
      ;;

    4)
      echo "🛠 Manual fix steps:"
      echo "1. Disable Watch unlock in System Settings"
      echo "2. Sign out and back into iCloud"
      echo "3. Unpair and re-pair your Apple Watch"
      echo "4. Re-enable Auto Unlock"
      read -rp "⏳ Press Enter when you've tried these..." _
      ;;

    5)
      echo "🧙 Repair Wizard:"
      echo "1. Reboot and toggle Watch unlock"
      echo "2. Sign out/in of iCloud"
      echo "3. Unpair/re-pair Apple Watch"
      echo "4. Cancel"
      read -rp "Choose [1–4]: " step
      case "$step" in
        1) echo "↪️ Reboot, then re-enable Watch unlock in System Settings" ;;
        2) echo "⚠️ Sign out of Apple ID in Settings, reboot, and sign back in" ;;
        3) echo "📱 Unpair from iPhone → reboot Mac → re-pair Watch" ;;
        *) echo "❌ Cancelled." ;;
      esac
      ;;

    6)
      echo "📦 Choose destination to save logs:"
      echo "1. Desktop"
      echo "2. Downloads"
      echo "3. Documents/unWatchDogLogs"
      echo "4. Custom path"
      read -rp "Select [1–4]: " location_choice

      case "$location_choice" in
        1) DEST="$HOME/Desktop" ;;
        2) DEST="$HOME/Downloads" ;;
        3) DEST="$HOME/Documents/unWatchDogLogs"; mkdir -p "$DEST" ;;
        4)
          read -rp "Enter full path: " custom_path
          mkdir -p "$custom_path" && DEST="$custom_path" || DEST="$HOME/Downloads"
          ;;
        *) DEST="$HOME/Downloads" ;;
      esac

      TMPDIR=$(mktemp -d)
      log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d > "$TMPDIR/autounlock_state.log" 2>/dev/null
      log show --predicate 'eventMessage CONTAINS "AWDL" OR eventMessage CONTAINS "bluetoothd"' --style syslog --last 1d > "$TMPDIR/bluetooth_awdl.log" 2>/dev/null
      log show --predicate 'eventMessage CONTAINS "LocalAuthentication" OR eventMessage CONTAINS "Apple Watch"' --style syslog --last 1d | grep -Ei "Watch|Auth|LAContext|kLAError" > "$TMPDIR/3rdparty_auth.log" 2>/dev/null
      ls -lah "$AUTO_UNLOCK_DIR" > "$TMPDIR/trust_file_listing.txt" 2>/dev/null

      cat <<EOF > "$TMPDIR/AI_analysis_instructions.txt"
# Apple Watch Authentication Diagnostic Logs

Analyze these logs to determine why Apple Watch unlock is failing on this Mac.

Included:
- Trust file listing
- AutoUnlock system logs
- Bluetooth/AWDL logs
- 3rd-party app auth logs (via LocalAuthentication)

Focus areas:
- Whether ltk.plist is missing or malformed
- Bluetooth/AWDL connection interruptions
- Failed biometric auth attempts in apps

Suggest possible causes and solutions.
EOF

      ZIPFILE="$DEST/auto_unlock_diagnostics_$(date +%Y-%m-%d_%H%M%S).zip"
      zip -r "$ZIPFILE" "$TMPDIR" >/dev/null
      rm -rf "$TMPDIR"
      echo "✅ Logs + AI prompt saved to: $ZIPFILE"
      ;;

    7)
      echo "👋 Exiting."
      exit 0
      ;;

    *)
      echo "❌ Invalid option."
      ;;
  esac
done