# Changelog

## Unreleased

- Its own repository, moved out of Haumea's `tools/server`, and renamed from haumea-server to
  haumea-telemetry (the multiplayer server is haumea-server now): `haumea_telemetry.py`, the
  `haumea-telemetry` service, user and folders. `deploy/migrate-from-haumea-server.sh` moves a
  running install, with a backup and automatic rollback.
- The tests' fake Discord reads multipart posts (an alert with the crash's details attached), as the
  server has sent them for a while: the two alert tests that failed pass again.
- CI: the tests on Python 3.10, 3.12 and 3.14.
