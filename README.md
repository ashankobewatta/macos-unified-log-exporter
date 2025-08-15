# macOS Unified Log Exporter

This script converts **macOS Unified Logs** (binary format) into a standard, SIEM-friendly log file.

It runs a LaunchDaemon that continuously captures logs from the `com.apple.security` subsystem
and writes them in syslog-style format to `/var/log/mac_unified_security.log`.  
It also sets up automatic log rotation.

---

## Features
- Continuous export of macOS Unified Logs
- Syslog-style plain-text output
- Log rotation (50MB max, 5 archives, compressed)
- Simple install: one script, no dependencies
- SIEM-ready

---

## Install
Run as root:
```bash
git clone https://github.com/kobeash/macos-unified-log-exporter.git
cd macos-unified-log-exporter
chmod +x install_macsec_logger.sh
sudo ./install_macsec_logger.sh
