#!/bin/sh
# Renames a deployed haumea-server (the telemetry and crash report server, from
# before it was called haumea-telemetry) to haumea-telemetry, keeping its data.
# Run with sudo from a folder holding this repo's files.
#
# - Stops haumea-server.service and backs everything up to /root first.
# - Renames its user and group (same ids, so file owners stay right).
# - Moves /var/lib/haumea-server, /etc/haumea-server (its paths in env updated)
#   and installs the code in /opt/haumea-telemetry, as haumea-telemetry.service.
# - Checks /healthz answers. If anything fails, it puts everything back as it was
#   and starts haumea-server again.
# The web server in front (nginx or Caddy) needs no change: it talks to the same port.
set -eu
[ "$(id -u)" = 0 ] || { echo "run it with sudo"; exit 1; }
HERE=$(cd "$(dirname "$0")/.." && pwd)
OLD=haumea-server
NEW=haumea-telemetry
FILES="haumea_telemetry.py access.py dashboard.py symbols.py symbolize.py privacy.html"
for f in $FILES haumea-telemetry.service; do
	[ -f "$HERE/$f" ] || { echo "$HERE/$f is missing"; exit 1; }
done
if systemctl is-active --quiet "$NEW"; then
	echo "$NEW is already running: nothing to do"
	exit 0
fi
id "$OLD" >/dev/null 2>&1 || { echo "no $OLD user here: nothing to rename (see DEPLOY.md for a new install)"; exit 1; }

BACKUP=/root/$OLD-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP"
echo "Backing up to $BACKUP"
systemctl stop "$OLD"
cp -a /var/lib/$OLD "$BACKUP/var-lib"
cp -a /etc/$OLD "$BACKUP/etc"
cp -a /opt/$OLD "$BACKUP/opt"
cp -a /etc/systemd/system/$OLD.service "$BACKUP/"

rollback() {
	echo "Something failed: putting $OLD back as it was"
	systemctl stop "$NEW" 2>/dev/null || true
	systemctl disable "$NEW" 2>/dev/null || true
	rm -f /etc/systemd/system/$NEW.service
	id "$NEW" >/dev/null 2>&1 && usermod -l "$OLD" "$NEW" 2>/dev/null || true
	getent group "$NEW" >/dev/null && groupmod -n "$OLD" "$NEW" 2>/dev/null || true
	rm -rf /var/lib/$OLD /etc/$OLD /opt/$OLD /var/lib/$NEW /etc/$NEW /opt/$NEW
	cp -a "$BACKUP/var-lib" /var/lib/$OLD
	cp -a "$BACKUP/etc" /etc/$OLD
	cp -a "$BACKUP/opt" /opt/$OLD
	cp -a "$BACKUP/$OLD.service" /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable "$OLD" >/dev/null 2>&1 || true
	systemctl start "$OLD"
	echo "$OLD is back. The backup stays in $BACKUP."
}
trap 'rollback' EXIT

usermod -l "$NEW" "$OLD"
groupmod -n "$NEW" "$OLD"
mv /var/lib/$OLD /var/lib/$NEW
mkdir -p /etc/$NEW
cp -a /etc/$OLD/. /etc/$NEW/
sed -i "s|/var/lib/$OLD|/var/lib/$NEW|g; s|/opt/$OLD|/opt/$NEW|g" /etc/$NEW/env
chgrp -R "$NEW" /etc/$NEW
mkdir -p /opt/$NEW
for f in $FILES; do
	install -m 644 "$HERE/$f" /opt/$NEW/
done
install -m 644 "$HERE/haumea-telemetry.service" /etc/systemd/system/
systemctl disable "$OLD" >/dev/null 2>&1 || true
rm -f /etc/systemd/system/$OLD.service
systemctl daemon-reload
systemctl enable "$NEW" >/dev/null 2>&1
systemctl start "$NEW"

# Is it answering? Where it listens, from its env (127.0.0.1:8787 if unset).
LISTEN=$(sed -n 's/^HAUMEA_LISTEN=//p' /etc/$NEW/env | tail -1)
LISTEN=${LISTEN:-127.0.0.1:8787}
ok=0
for i in 1 2 3 4 5 6 7 8 9 10; do
	if curl -fsS "http://$LISTEN/healthz" >/dev/null 2>&1; then ok=1; break; fi
	sleep 1
done
[ "$ok" = 1 ] || { echo "$NEW didn't answer on http://$LISTEN/healthz"; exit 1; }

trap - EXIT
rm -rf /etc/$OLD /opt/$OLD
echo "Done: $NEW is running and answering on http://$LISTEN/healthz."
echo "The backup of the old setup stays in $BACKUP (delete it once you're happy)."
