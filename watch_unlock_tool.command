#!/bin/bash

AUTO_UNLOCK_DIR="$HOME/Library/Sharing/AutoUnlock"
NEEDED_FILES=("ltk.plist")

read -rp "📝 Show logs and raw output in terminal? (y/n): " verbose_choice
VERBOSE=false
[[ "$verbose_choice" =~ ^[Yy]$ ]] && VERBOSE=true

# Function: Parse LocalAuthentication logs and explain errors
function parse_local_auth_logs() {
  echo "🔍 Checking third-party app unlock failures via Apple Watch..."
  raw_log=$(log show --predicate 'eventMessage CONTAINS "LocalAuthentication" OR eventMessage CONTAINS "Apple Watch"' --style syslog --last 1d 2>/dev/null)
  filtered=$(echo "$raw_log" | grep -Ei "Watch|Auth|LAContext|kLAError|biometric|unlock|failed|denied")

  if [[ "$VERBOSE" == true ]]; then echo "$filtered"; fi

  echo ""
  echo "📘 Interpreted results:"
  echo "$filtered" | while read -r line; do
    case "$line" in
      *kLAErrorAuthenticationFailed*) echo "❌ Authentication failed — Watch was present but not accepted." ;;
      *kLAErrorPasscodeNotSet*) echo "🔒 Apple Watch must have a passcode set for unlock to work." ;;
      *"No paired device"*|*"not paired"*) echo "🔗 No Apple Watch found or it’s not paired correctly." ;;
      *kLAErrorUserCancel*) echo "🚫 Unlock was cancelled by user or system (maybe screen lock interrupted it)." ;;
      *kLAErrorWatchNotAvailable*) echo "📴 Your Watch wasn't detected during the auth attempt." ;;
      *Timed\ out*|*timeout*|*took\ too\ long*) echo "⏱️ Authentication timed out. Bluetooth or Watch response may be lagging." ;;
      *kLAErrorSystemCancel*) echo "❌ Authentication cancelled by system (possibly due to sleep/wake or logout)." ;;
      *kLAErrorAppCancel*) echo "🛑 App canceled the authentication — could be app-specific bug." ;;
      *kLAErrorInvalidContext*) echo "⚠️ Invalid auth context — may need to restart the app or log out and in." ;;
      *kLAErrorWatchNotPaired*) echo "🔗 Watch is not paired with this Mac." ;;
      *kLAErrorBiometryNotAvailable*) echo "❌ Biometry not available — system can't access your Watch’s auth features." ;;
      *kLAErrorBiometryNotEnrolled*) echo "⚠️ No biometrics enrolled. Ensure Watch passcode is set." ;;
      *) if [[ "$VERBOSE" == true ]]; then echo "🔹 $line"; fi ;;
    esac
  done
}

function summarize_autounlock_logs() {
  log=$(log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d 2>/dev/null | tail -n 50)
  echo "$log" | while read -r line; do
    case "$line" in
      *AutoUnlock\ state:0*) echo "🔄 State: 0 = Unknown" ;;
      *AutoUnlock\ state:1*) echo "✅ State: 1 = Active (should be working)" ;;
      *AutoUnlock\ state:2*) echo "🔐 State: 2 = Inactive — password required" ;;
      *AutoUnlock\ state:3*) echo "🟢 State: 3 = Active" ;;
      *) [[ "$VERBOSE" == true ]] && echo "🔹 $line" ;;
    esac
  done
}

function summarize_bluetooth_awdl_logs() {
  log=$(log show --predicate 'eventMessage CONTAINS "bluetoothd" OR eventMessage CONTAINS "AWDL"' --style syslog --last 1d 2>/dev/null | tail -n 50)
  echo "$log" | while read -r line; do
    case "$line" in
      *AWDL\ ON*) echo "📶 AWDL is ON — Discovery mode working." ;;
      *Infra\ Priority*) echo "📡 Infra Priority traffic: $(echo "$line" | sed 's/.*Infra Priority/Infra Priority/')";;
      *Tx:0\ Rx:0*) echo "⚠️ No data being transmitted — Watch may not be active or connected." ;;
      *peer*) echo "👥 Peers seen: $line" ;;
      *) [[ "$VERBOSE" == true ]] && echo "🔹 $line" ;;
    esac
  done
}

# Main menu loop
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
      summarize_autounlock_logs
      ;;

    2)
      while true; do
        echo ""
        echo "🧪 Diagnostics Menu"
        echo "1. AutoUnlock state logs"
        echo "2. Bluetooth + AWDL logs"
        echo "3. Trust file check"
        echo "4. 3rd-party app unlock diagnostics"
        echo "5. Run all diagnostics"
        echo "6. Return to main menu"
        read -rp "Select an option [1–6]: " log_choice
        echo ""

        case "$log_choice" in
          1)
            echo "🔍 AutoUnlock state logs:"
            summarize_autounlock_logs
            ;;
          2)
            echo "📡 Bluetooth + AWDL logs:"
            summarize_bluetooth_awdl_logs
            ;;
          3)
            echo "📂 Trust file check:"
            for file in "${NEEDED_FILES[@]}"; do
              [ -f "$AUTO_UNLOCK_DIR/$file" ] && echo "✅ Found: $file" || echo "❌ Missing: $file"
            done
            ;;
          4)
            parse_local_auth_logs
            ;;
          5)
            echo "⏳ Running all diagnostics..."
            summarize_autounlock_logs
            summarize_bluetooth_awdl_logs
            for file in "${NEEDED_FILES[@]}"; do
              [ -f "$AUTO_UNLOCK_DIR/$file" ] && echo "✅ Found: $file" || echo "❌ Missing: $file"
            done
            parse_local_auth_logs
            ;;
          6) break ;;
          *) echo "❌ Invalid option." ;;
        esac
      done
      ;;

    3)
      echo "🧼 Resetting trust files and services..."
      rm -rf "$AUTO_UNLOCK_DIR"/*
      sudo pkill sharingd
      sudo pkill bluetoothd
      echo ""
      read -rp "⚠️ Restart loginwindow? (logs you out) [y/N]: " lw_opt
      [[ "$lw_opt" =~ ^[Yy]$ ]] && launchctl kickstart -k gui/$(id -u)/com.apple.loginwindow
      echo "⚙️ Opening Touch ID settings..."
      open "x-apple.systempreferences:com.apple.TouchID-Settings.extension"
      ;;

    4)
      echo "🛠 Manual trust repair:"
      echo "• Disable unlock in System Settings"
      echo "• Sign out/in of iCloud"
      echo "• Unpair/re-pair Watch"
      read -rp "Press Enter when done..." _
      ;;

    5)
      echo "🧙 Repair wizard:"
      echo "1. Reboot and toggle unlock"
      echo "2. Sign out/in of iCloud"
      echo "3. Unpair/re-pair Apple Watch"
      echo "4. Cancel"
      read -rp "Choose [1–4]: " step
      case "$step" in
        1) echo "↪️ Reboot, then re-enable Watch unlock" ;;
        2) echo "⚠️ Sign out of Apple ID → reboot → sign in" ;;
        3) echo "📱 Unpair from iPhone → reboot → re-pair" ;;
        *) echo "❌ Cancelled." ;;
      esac
      ;;

    6)
      echo "📦 Save logs to:"
      echo "1. Desktop"
      echo "2. Downloads"
      echo "3. Documents/unWatchDogLogs"
      echo "4. Custom path"
      read -rp "Select [1–4]: " loc
      case "$loc" in
        1) DEST="$HOME/Desktop" ;;
        2) DEST="$HOME/Downloads" ;;
        3) DEST="$HOME/Documents/unWatchDogLogs"; mkdir -p "$DEST" ;;
        4)
          read -rp "Path: " custom
          mkdir -p "$custom" && DEST="$custom" || DEST="$HOME/Downloads"
          ;;
        *) DEST="$HOME/Downloads" ;;
      esac

      TMP=$(mktemp -d)
      log show --predicate 'eventMessage contains "AutoUnlock state"' --style syslog --last 1d > "$TMP/autounlock.log"
      log show --predicate 'eventMessage CONTAINS "AWDL" OR eventMessage CONTAINS "bluetoothd"' --style syslog --last 1d > "$TMP/bluetooth.log"
      log show --predicate 'eventMessage CONTAINS "LocalAuthentication" OR eventMessage CONTAINS "Apple Watch"' --style syslog --last 1d | grep -Ei "Watch|Auth|kLAError" > "$TMP/thirdparty.log"
      ls -lah "$AUTO_UNLOCK_DIR" > "$TMP/trustfiles.txt" 2>/dev/null

      cat <<EOF > "$TMP/README_AI.txt"
Analyze these logs to explain Apple Watch unlock failures:

- autounlock.log = macOS system unlock state
- bluetooth.log = AWDL/Bluetooth stability
- thirdparty.log = App-level auth attempts using LocalAuthentication
- trustfiles.txt = ltk.plist presence and state

Focus on recurring kLAError codes or timeouts.
EOF

      ZIP="$DEST/unlock_diagnostics_$(date +%Y-%m-%d_%H%M%S).zip"
      zip -r "$ZIP" "$TMP" >/dev/null
      rm -rf "$TMP"
      echo "✅ Logs saved to: $ZIP"
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