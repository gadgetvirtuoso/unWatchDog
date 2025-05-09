#!/bin/bash

AUTO_UNLOCK_DIR="$HOME/Library/Sharing/AutoUnlock"
NEEDED_FILES=("ltk.plist" "watch-companion-mapping.plist")

# Ask once at launch if user wants verbose output
read -rp "📝 Show logs and raw output in terminal? (y/n): " verbose_choice
if [[ "$verbose_choice" =~ ^[Yy]$ ]]; then
  VERBOSE=true
else
  VERBOSE=false
fi

while true; do
  echo ""
  echo "🧭 Apple Watch Unlock Toolkit"
  echo "1️⃣  Check AutoUnlock state (with analysis)"
  echo "2️⃣  Run diagnostics (trust + Bluetooth + state)"
  echo "3️⃣  Reset trust chain and services"
  echo "4️⃣  Fix missing watch-companion trust chain"
  echo "5️⃣  Repair wizard (step-by-step user guidance)"
  echo "6️⃣  Package logs for ChatGPT review"
  echo "7️⃣  Quit"
  read -rp "Choose an option [1-7]: " choice
  echo ""

  case "$choice" in
    1)
      echo "⏳ Fetching AutoUnlock state logs... this may take a few seconds."
      echo "(Press Ctrl+C to cancel and return to the menu.)"
      sleep 1
      log_output=$(log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d 2>/dev/null | tail -n 20)
      [ "$VERBOSE" = true ] && echo "$log_output"
      state_line=$(echo "$log_output" | grep "AutoUnlock state:" | tail -n 1)
      state=$(echo "$state_line" | grep -o "AutoUnlock state:[0-9]" | cut -d: -f2)
      echo ""
      case "$state" in
        0) echo "🟡 AutoUnlock state: 0 (Unknown) — just after boot or setup." ;;
        1) echo "🟢 AutoUnlock state: 1 (Active) — your Watch should unlock your Mac." ;;
        2) echo "🔴 AutoUnlock state: 2 (Inactive) — password login is required." ;;
        *) echo "❓ AutoUnlock state unknown or not found in logs." ;;
      esac
      ;;

    2)
      echo "⏳ Running diagnostics... this may take 5–15 seconds."
      echo "(Press Ctrl+C to cancel and return to the menu.)"
      sleep 1
      echo "📄 Checking trust files in: $AUTO_UNLOCK_DIR"
      trust_status="ok"
      for file in "${NEEDED_FILES[@]}"; do
        if [ -f "$AUTO_UNLOCK_DIR/$file" ]; then
          echo "✅ Found: $file"
        else
          if [ "$file" == "watch-companion-mapping.plist" ]; then
            echo "⚠️ Missing: $file — Auto Unlock may fail silently."
          else
            echo "❌ Missing: $file"
          fi
          trust_status="missing"
        fi
      done
      echo ""
      echo "📡 Scanning Bluetooth/AWDL logs..."
      bt_log=$(log show --predicate 'eventMessage CONTAINS "AWDL" OR eventMessage CONTAINS "bluetoothd"' --style syslog --last 1d 2>/dev/null | tail -n 50)
      [ "$VERBOSE" = true ] && echo "$bt_log"
      echo ""
      state_line=$(log show --predicate 'eventMessage contains "AutoUnlock state:"' --style syslog --last 1d 2>/dev/null | grep "AutoUnlock state:" | tail -n 1)
      state=$(echo "$state_line" | grep -o "AutoUnlock state:[0-9]" | cut -d: -f2)
      echo "🧾 Summary:"
      [ "$trust_status" = "missing" ] && echo "❌ Trust files missing or incomplete." || echo "✅ Trust files present."
      echo "$bt_log" | grep -qi "error" && echo "⚠️ Bluetooth/AWDL errors detected." || echo "✅ No major Bluetooth errors found."
      case "$state" in
        1) echo "🟢 AutoUnlock is active." ;;
        2) echo "🔴 AutoUnlock is inactive." ;;
        *) echo "❓ AutoUnlock state not detected." ;;
      esac
      ;;

    3)
      echo "🧼 Resetting trust chain and related services..."
      missing_files=0
      for file in "${NEEDED_FILES[@]}"; do
        [ ! -f "$AUTO_UNLOCK_DIR/$file" ] && missing_files=1
      done
      if [ $missing_files -eq 1 ]; then
        read -p "⚠️ Trust files are incomplete. Delete trust data and restart services? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
          echo "🧨 Deleting trust records..."
          rm -rf "$AUTO_UNLOCK_DIR"/*
          echo "🔄 Restarting sharingd and bluetoothd..."
          sudo pkill sharingd
          sudo pkill bluetoothd
          echo "💡 Nudging loginwindow..."
          launchctl kickstart -k gui/$(id -u)/com.apple.loginwindow
          echo "⚙️ Opening Touch ID settings..."
          open "x-apple.systempreferences:com.apple.TouchID-Settings.extension"
        else
          echo "❌ Skipped cleanup."
        fi
      else
        echo "✅ Trust files look intact. No reset needed."
      fi
      ;;

    4)
      echo "🛠 Manual Fix: watch-companion-mapping.plist is missing"
      echo "Try the following methods to fix:"
      echo "1. Reboot and re-enable Watch unlock"
      echo "2. Sign out/in of iCloud on this Mac"
      echo "3. Unpair and re-pair your Apple Watch"
      echo ""
      read -p "Press Enter when you've tried one or more fixes..." _
      ;;

    5)
      echo "🧙‍♂️ Repair Wizard: Fixing Trust Chain"
      echo "Choose a repair method:"
      select method in \
        "Reboot and re-enable Watch unlock" \
        "Sign out/in of iCloud" \
        "Unpair and re-pair Apple Watch" \
        "Cancel"; do
        case $REPLY in
          1)
            echo "🔁 Reboot your Mac."
            echo "Then open System Settings > Touch ID and toggle Watch unlock OFF and ON again."
            read -p "⏳ Press Enter after you've done this..." ;;
          2)
            read -p "⚠️ Are you sure you want to sign out of iCloud? (y/n): " confirm
            [[ "$confirm" =~ ^[Yy]$ ]] && echo "➡️ Go to System Settings > Apple ID and sign out, then reboot and sign back in." && read -p "⏳ Press Enter when done..." ;;
          3)
            echo "💬 Open Watch app → Tap ⓘ next to your watch → Unpair → Reboot Mac → Re-enable unlock."
            read -p "⏳ Press Enter when done..." ;;
          4)
            echo "❌ Cancelling." ;;
        esac
        break
      done
      echo "🔍 Rechecking for trust file..."
      if [ -f "$AUTO_UNLOCK_DIR/watch-companion-mapping.plist" ]; then
        echo "✅ Trust file found."
      else
        echo "❌ Still missing. Consider Apple support or deeper reset."
      fi
      ;;

    6)
      echo "📦 Packaging logs for upload..."
      TMPDIR=$(mktemp -d)
      AUTOLOG="$TMPDIR/autounlock_state.log"
      BTLOG="$TMPDIR/bluetooth_awdl.log"
      TRUSTLIST="$TMPDIR/trust_file_listing.txt"
      log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d 2>/dev/null > "$AUTOLOG"
      log show --predicate 'eventMessage CONTAINS "AWDL" OR eventMessage CONTAINS "bluetoothd"' --style syslog --last 1d 2>/dev/null > "$BTLOG"
      ls -lah "$AUTO_UNLOCK_DIR" > "$TRUSTLIST" 2>/dev/null
      ZIPFILE="$HOME/Downloads/auto_unlock_diagnostics_$(date +%Y-%m-%d).zip"
      zip -r "$ZIPFILE" "$TMPDIR" >/dev/null 2>&1
      echo "✅ Logs saved to:"
      echo "$ZIPFILE"
      rm -rf "$TMPDIR"
      ;;

    7)
      echo "👋 Exiting. No changes made."
      exit 0
      ;;

    *)
      echo "❌ Invalid option. Try again."
      ;;
  esac
done
