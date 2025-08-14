#!/bin/bash
# macOS Unified Log → Syslog-style file for SIEM
# Installs a LaunchDaemon to capture security logs into /var/log/mac_unified_security.log

set -e

LOG_SCRIPT="/usr/local/bin/macsec-logger.sh"
PLIST_FILE="/Library/LaunchDaemons/com.mycompany.macsec-logger.plist"
LOG_FILE="/var/log/mac_unified_security.log"
ROTATE_CONF="/etc/newsyslog.d/macsec-logger.conf"

echo "[+] Creating log capture script..."
cat << 'EOF' > "$LOG_SCRIPT"
#!/bin/bash
/usr/bin/log stream --style syslog --predicate 'subsystem == "com.apple.security"' >> /var/log/mac_unified_security.log 2>&1
EOF
chmod 755 "$LOG_SCRIPT"

echo "[+] Creating LaunchDaemon plist..."
cat << EOF > "$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mycompany.macsec-logger</string>
    <key>ProgramArguments</key>
    <array>
        <string>$LOG_SCRIPT</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>
    <key>StandardErrorPath</key>
    <string>$LOG_FILE</string>
</dict>
</plist>
EOF
chmod 644 "$PLIST_FILE"

echo "[+] Setting up log rotation..."
mkdir -p /etc/newsyslog.d
cat << EOF > "$ROTATE_CONF"
# Rotate when >50M, keep 5 archives, compress old logs
$LOG_FILE  644  5  50  *  Z
EOF

echo "[+] Loading LaunchDaemon..."
launchctl bootout system "$PLIST_FILE" 2>/dev/null || true
launchctl bootstrap system "$PLIST_FILE"

echo "[+] Done!"
echo "Logs are now being written to: $LOG_FILE"
echo "Log rotation is configured in: $ROTATE_CONF"
