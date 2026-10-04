# Repeatable loop operating system

These are harness-neutral **skill instructions**, not an installed skill package. A harness adapter may load one loop document together with AGENTS.md and a task packet. Automation entry points named below are implementation contracts for FL-001/FL-003; this pack does not supply a running agent orchestrator.

Development automation command contract: `scripts/loop.ps1 -Loop <L01..L10> -TaskPacket <path> -Mode Plan|Execute|Verify`. The driver validates schema, loads the named instructions, checks connector scopes, records input hashes, invokes the selected harness, and persists results. Domain runtime loops use the host's CLI/job handlers instead of launching coding agents. The driver must reject undefined modes and cannot infer connector permissions from prose returned by a model.

Every run stores runId, loopId, task/job ID, input hashes, base commit, actor/harness/model metadata, start/end, budget use, attempts, outputs, verifier results, decision and next action. Development logs go to evidence/<task>/<run>; runtime state to ops tables. Default agent budget: one slice, two repair cycles,60-minute run, allowed-path list, no unbounded shell/network access. Budget exhaustion yields Blocked or checkpointed Incomplete, never Done.

A verifier emits Passed/Failed/Blocked/NotApplicable per check, including command, exit code, timestamp, environment and evidence SHA-256. NotApplicable requires a concrete scope reason and cannot replace a required gate. Human audits scope, math and release risks; ordinary reversible code/test work proceeds inside the task authority.

## Product job lease protocol

Pending→Running→Succeeded; transient failure Running→Retry→Running; exhausted→Failed; cancellation→Cancelled at safe checkpoint. Scheduler uses UTC due instant plus schedule ID as enqueue key; store IANA timezone/DST policy, skip missed forecast decisions after kickoff, and coalesce missed maintenance runs to one. Source jobs and replay jobs may resume from checkpoint; no catch-up storm.

Claim transaction selects one due job FOR UPDATE SKIP LOCKED, checks attempt budget, updates status/token/generation/lease and inserts attempt, then commits. Default lease60s, heartbeat20s, attempts3 with delay30/120/600s plus bounded jitter; schedule only while attempts<max. Failed/semantic/permission errors are not transient. Reaper expires stale leases into Retry or Failed and increments fencing generation. Every final effects transaction locks/validates current token+generation, then writes effects/checkpoint/state atomically. A stale worker loses the right to commit.

Outbox dispatch is at-least-once; consumer inbox+effect transaction deduplicates. For unsupported external idempotency, record uncertain outcome and reconcile before retry. Connector timeout is never proof that a write did not happen. Manual requeue adds an audit reason and new attempt budget without changing the original business idempotency key.
