# Deployment, installation and upgrades

## Selected topology

Windows11 x64 personal installation: FootLens.Host runs as a local service or explicitly launched background process; Desktop connects to127.0.0.1:5188; PostgreSQL18 runs locally or on an explicitly configured private host. Baseline service deployment has a dedicated restricted account and delayed/retry startup until PostgreSQL is ready. The desktop process can close without cancelling durable jobs. Manual CLI mode is available for recovery, not a second concurrent scheduler unless leader/lease logic permits it.

Artifacts: self-contained win-x64 Desktop and Host publish outputs, Tools CLI, migration bundle/reviewed SQL, model/config artifacts, SBOM/licence notices, SHA-256 manifest, operator/user guide and release notes. Exact SDK/runtime/package/database image versions are in the manifest. Self-contained runtime security fixes require republishing; monthly servicing is a maintenance task. No automatic updater in v1.0; updates are explicit and recoverable.

## Install checklist

1. Verify release hashes/signature/trust instruction. Install supported PostgreSQL18 patch from official distribution. Create dedicated database and migrator/runtime/backup roles; generate credentials outside Git.
2. Choose data root, e.g. an ACL-restricted ProgramData/FootLens directory, with subdirectories artifacts, logs, backups, config. Provision API token using OS protection. Bind loopback; PostgreSQL must not listen publicly.
3. Use migrator identity to apply reviewed migration bundle against empty store. Check schema version and grants; remove migrator secret from runtime configuration.
4. Configure connection via protected service configuration, artifact root and API token. Validate disk space/timezone/UTC clock. Register service with least privileges; configure restart backoff and log rotation.
5. Start host; liveness then authenticated readiness. Start Desktop and pair local token. Import the shipped synthetic sample, create journal entry and inspect result.
6. Run baseline backup/restore drill to a separate DB and artifact root. Record installed hashes, schema and operator. Mark operational only after smoke and recovery checks.

No script in this documentation has installed a service or database. FL-028 must implement idempotent installation scripts with preflight and dry-run, preserving existing data. Uninstall removes binaries/service and asks explicitly before deleting data/backups; routine upgrade never deletes them.

## Upgrade procedure

Freeze new admissions/schedules; drain or checkpoint jobs. Verify a recoverable database+artifact backup. Read migration compatibility and estimate space/lock duration on staging. Test N-1 restored copy first. Apply expansion migrations with separate migrator, publish the exact tested binaries, restart, run readiness/journal/queue/ledger smoke, then resume schedules. Retain old binaries and model artifacts.

Rollback within backward-compatible schema: stop new work, restore previous approved binaries/config/model hashes and run smoke. Incompatible migration: stop service, restore database and artifacts together to the tested backup, reconcile lost work since backup from immutable source/queue receipts and report actual recovery point. Do not run arbitrary EF Down migrations against production. Forward-fix may be safer if evidence supports it; owner decision records trade-off and outcome.

## Backup consistency

Use pg_dump custom-format or a documented physical/PITR method; logical dump is the default. To bind artifact files: pause artifact publication/retention, capture a consistent DB snapshot/dump, list referenced artifact hashes, copy their immutable content, verify hashes and write a manifest, then resume. Durable jobs can checkpoint during pause; no partial filesystem reference is accepted. Restore DB and referenced artifact manifest in an isolated environment, check foreign keys/schema, reproduce selected journal/report outputs and only then mark backup verified.

Targets: daily verified backup,7 daily/4 weekly/12 monthly copies, RPO≤24h and RTO≤4h for the initial personal workload. Targets are not guarantees until measured restore. Optional encrypted off-host copy uses a configured permitted destination; failure alerts locally and does not claim backup success.
