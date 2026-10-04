# Operations and maintenance

## Routine schedule

| Cadence | Work | Evidence / escalation |
|---|---|---|
| On startup | schema compatibility, artifacts, clock, DB and overdue leases | readiness503 if incompatible; recover jobs with fencing |
| Daily | job failures, source staleness, backup, disk space and queue age | local Operations alerts with dedupe key |
| Weekly | settled prediction quality, calibration/coverage, pending aliases and quarantine | cohort report; no automatic promotion |
| Monthly | supported patches/dependencies, restore drill, retention dry-run and docs | maintenance task with test/release evidence |
| Quarterly / major change | disaster recovery and release/role review | measured RTO/RPO and updated risks |

Default alerts: source older than its admitted cadence+grace; three exhausted jobs in1h; forecast failures>5% of last100 requests (minimum100); free disk<10GB or<10%; DB unavailable>60s; backup unverified>24h. All thresholds versioned. Alerts identify affected cohort, last good run and next action; acknowledge is different from resolve. External notifications disabled until a destination/channel is explicitly configured and authorised.

## Calibration drift

Evaluate newly settled immutable predictions weekly. Cohort league/market/model with≥200 settled events, trailing90 days or longer until sample gate; compare against approved baseline on identical metric convention. Warn when Brier degradation>.02 and paired/block bootstrap lower95% bound>0, or ECE>.05 with supported bins, for two consecutive runs. Thresholds are operational defaults requiring validation; overlapping windows are not independent evidence. Sparse cohort → InsufficientEvidence. Check source/rules/coverage changes before blaming model.

Critical structural violations (invalid mass, invalid source definition, detected future leakage) quarantine immediately. Statistical drift creates review and may set Degraded via policy; replacement still requires approved protocol and promotion evidence. Retain old predictions and model. Refit and recalibration are jobs in an experiment/approval lifecycle, not overwrite operations.

## Observability

Structured logs: UTC timestamp, severity, event code, correlation/job/prediction/run IDs, duration and safe reason. Metrics: queue age, leased/stale jobs, retries, import throughput/quarantine, forecast failure/fallback rate, DB latency, missing coverage, numerical tail failure, model drift and disk/backup age. Log rotation10 files×20MB default; redacted diagnostic logs90 days. Audit history is separate and retained with referenced artifacts.

Health/live answers process responsiveness; health/ready checks DB connectivity/schema and required artifact availability. A market-specific quarantine should not make unrelated markets globally unavailable. Operations workspace provides searchable audit and retry/export actions with reasons and optimistic version checks.

## Retention and change control

Dry-run retention computes reference graph from database+manifests, lists proposed deletions and bytes, refuses referenced model/raw/forecast evidence and verifies backups. Execute only eligible unreferenced caches/staging/logs under documented policy. Record deletion receipts. Licence-mandated removal creates an explicit evidence loss event and affected readiness change. Store source payload changes as new revisions.

Patch development runs L01→L04 in isolated worktree, then L09. Schema/model changes use the same gates as initial implementation. End-of-support replacement requires ADR and compatibility tests. Maintain a known-issues register with severity/owner/workaround/repro/test, never a hidden TODO backlog inside chat.
