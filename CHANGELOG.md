# Changelog

## Unreleased

- Its own repository, moved out of Haumea's `tools/server`, and renamed from haumea-server to
  haumea-telemetry (the multiplayer server is haumea-server now): `haumea_telemetry.py`, the
  `haumea-telemetry` service, user and folders. `deploy/migrate-from-haumea-server.sh` moves a
  running install, with a backup and automatic rollback.
- Known: `test_alerts_batched_with_429` and `test_issue_key_and_regression` were failing before the move.
