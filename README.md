# haumea-telemetry

The telemetry and crash report server for [Haumea Studio](https://github.com/itsneufox/Haumea-Studio).
Haumea's daily pings go to `https://telemetry.itsneufox.xyz/haumea/telemetry/ping` and its crash
reports to `https://reports.itsneufox.xyz/haumea/reports`; this is the server for both, plus the
dashboard behind Cloudflare Access and the symbols that turn crash stacks into names and lines.

One Python file and a few helpers, standard library only, about 30 MB of memory.

- `haumea_telemetry.py`: the service (pings, reports, alerts to Discord, the dashboard)
- `dashboard.py`, `access.py`: the dashboard and its Cloudflare Access check
- `symbols.py`, `symbolize.py`: build symbols, and naming a report's stack offline
- `privacy.html`: what it keeps, served at `/privacy`
- `haumea-telemetry.service`, `Caddyfile`, `nginx-*.conf`: deploying it ([DEPLOY.md](DEPLOY.md))
- `test_telemetry_server.py`: its tests (`python3 -m unittest test_telemetry_server.py`)


Haumea's own tests check its crash reports against this server's `validate_report`: they look for
this repo beside the Haumea checkout (or in `HAUMEA_TELEMETRY_DIR`).

GPL-2.0-or-later, as Haumea.
