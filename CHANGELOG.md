# Changelog

## Unreleased

- Its own repository, moved out of Haumea's `tools/server`, and renamed from haumea-server to
  haumea-telemetry (the multiplayer server is haumea-server now): `haumea_telemetry.py`, the
  `haumea-telemetry` service, user and folders.
- The tests' fake Discord reads multipart posts (an alert with the crash's details attached), as the
  server has sent them for a while: the two alert tests that failed pass again.
- CI: the tests on Python 3.10, 3.12 and 3.14.
- Fixed: right after the machine booted, the dashboard turned every Cloudflare Access sign-in away for
  up to a minute (the first key fetch waited as if one had been made at boot).
