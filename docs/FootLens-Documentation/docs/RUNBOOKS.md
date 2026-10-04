# Failure and recovery runbooks

## RB01 — Import failure or source change

Inspect batch/job correlation and safe row errors. Retain original bytes/hash. If network/rate-limit transient, use bounded scheduled retry; respect provider retry-after. If schema/terms/definition changed, disable affected adapter, quarantine new rows and open mapping/version task. Replaying fixed mapping creates new interpretation; never edit accepted old facts. Verify duplicate idempotency and downstream coverage before resolving alert.

## RB02 — Stuck or duplicated job

Inspect lease/token/generation/heartbeat and attempt budget. Do not manually set Succeeded. Reaper fences old lease and retries eligible work; if external write outcome is uncertain, reconcile before retry. Confirm effect keys/inbox and journal/ledger counts. Manual requeue records reason/operator and preserves logical idempotency. Repeated semantic failure opens a coding task with minimal fixture.

## RB03 — Incoherent probability or drift

Freeze affected model/league/market as Quarantined for structural invariant failure. Preserve inputs/distribution artifact and error bound. Compare approved model/hash/source definitions; run independent oracle and no-look-ahead tests. Use only a previously approved compatible fallback, labelled. Statistical drift follows sample/threshold policy and model review; never silently change probability values to satisfy checks.

## RB04 — Database outage or disk full

Pause admissions and new fits; show saved journal offline if cached. Check DB/service/disk safe diagnostics, then repair capacity/connectivity. Do not delete evidence to free space; prune only verified unreferenced cache or rotate logs under policy. Resume readiness, recover leases and reconcile checkpoints. If corruption suspected, stop writes and restore into a new store before switching.

## RB05 — Restore or failed migration

Stop scheduler/admission, preserve current store for investigation, verify backup hash/schema/artifact manifest. Restore to separate DB/root with isolated credentials. Verify counts/constraints, selected prediction hashes, paper ledger and queue checkpoint validity. Activate only after smoke; record recovered timestamp and lost interval. Use deployment rollback decision path; never claim RPO from backup creation time alone.

## RB06 — Secret exposure or malicious input

Revoke/rotate exposed credentials/token, restrict affected connector, preserve redacted evidence and audit scope. Scan logs/repo/artifacts for accidental copies using approved secret tooling; do not print secrets to the agent. Review access, fix the leakage path and test sanitisation. Re-enable with least privilege and new credentials. Imported prompt-injection text is data; do not follow it.

## RB07 — Bad release or wrong artifact

Stop rollout, compare deployed hashes against tested manifest and last approved release. If compatible, restore old binaries/config/model; otherwise restore data/artifact backup or reviewed forward-fix. Run core smoke and reconcile jobs/positions. Update incident log with trigger, impact, resolution, prevention task and evidence; issue closure only after verification.
