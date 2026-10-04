# Vibe coding playbook — constrained, evidence-driven loops

## Working agreement

Use AI to execute concrete slices quickly while keeping domain contracts stable. The owner chooses product goals, checks risky trade-offs and audits releases. Agents propose diffs, tests and evidence. No agent's fluent summary is proof of correctness. The repository and durable run records are the working memory; chat context is disposable.

A slice is one user-visible behaviour through API, application/domain, persistence, UI where needed and tests. Example: “import one completed fixture and show its provenance” is a slice. “build all repositories” is a technical layer task and should be tied to a slice. Target one coherent review, normally1–2 days of human-equivalent work; split if touched modules/acceptance cannot be reviewed together. File-count/size limits are review signals, not reasons to omit necessary work.

## Roles and routing

| Role | Responsibility | Cannot claim alone |
|---|---|---|
| Architect | reconcile contracts/ADRs and scope | implementation validated without tests |
| Orchestrator | choose ready task, freeze packet, own state | override failed acceptance |
| Coder/worker | implement allowed slice and focused tests | self-certify independent review |
| Designer | refine flows/accessibility for accepted scope | insert statistical semantics |
| Reviewer | inspect exact commit, regressions, security/math | change production without task authority |
| Verifier | run specified commands, check evidence/hash/DoD | treat skipped tests as pass |

These are roles, not six mandatory processes. Default sequential implementation and fresh-context review. Concurrent workers require explicitly allocated non-overlapping tasks, independent worktrees and disposable DBs. One migration owner. Harness defaults are Cursor and VSCode, with optional adapters; domain instructions never depend on one model's private tools.

## Start each loop with a task packet

Required fields: task ID, requirement IDs, goal, exact commit, dependencies, authoritative docs, allowed paths, forbidden changes, inputs/fixture hashes, acceptance checks, test command names, connector scopes, budgets and stop rules. Use templates/task-packet.json. Read existing code and AGENTS before edits. Inspect Git status; preserve unrelated user changes. Verify dependencies are actually merged, not merely claimed complete in a conversation.

## Ask for code

Use prompts/03-vertical-slice.md. Specify behaviour, invariants, expected failure states and a fixture. Ask for the smallest complete implementation that passes independent acceptance; include no-new-dependency constraint unless task already authorises one. Require code+tests+docs and an evidence handoff. Do not ask for “the whole production app” in one turn.

Good example:

> Implement FL-004 at the task packet's base commit. Import the supplied canonical CSV through the API, preserving raw hash and record diagnostics. Unknown team aliases quarantine rows. Repeating the same payload/mapping/policy creates no duplicate facts. Touch only Ingestion, its Infrastructure store, endpoint and tests. Add actual PostgreSQL duplicate/restart tests. Return diff summary, exact commands/results and unresolved acceptance. Do not change temporal or alias rules to make the fixture pass.

## Ask for tests

Use prompts/10-test-generation.md. Request observable behaviour and adversarial cases, not a mirror of private functions. For numerical code provide independently computed oracle values, tolerances and invalid-domain tests. For jobs kill a worker around commit boundaries; for EF test real Postgres constraints. Ask the agent to describe what mutant/bug each critical test would catch. A test whose expected value comes from the implementation under test is not an oracle.

> Test FL-014 quarter-line settlement using Over2.75 at2,3,4 goals and handicap-0.25 on a draw. Verify gross/cost net returns, exhaustive mass, void refund and duplicate delivery. Use hand-calculated expected values. Do not add a new runner.

## Ask for refactoring

Freeze behaviour and existing acceptance first. State the coupling/performance problem and allowed module boundary; require no semantic change, before/after evidence and migration compatibility. Do not combine math changes with broad renaming. Example: move fixture-selection orchestration out of a WinForms handler into a presenter; preserve API DTOs, cancellation and stale-response tests.

## Prevent drift

Use the pack's precedence order and stable IDs. Update an ADR for intentional design change before relying on it. CI checks forbidden project/namespace references, package allowlist, generated schema drift, probability invariants and prompt/state schemas. Keep a decision log; do not let agents infer a new stack from a package suggestion. New libraries require a specific justification and locked licence/transitive graph. No hidden fallback to remote ML.

Stop a task when acceptance requires new scope, a numerical invariant fails, the source cannot prove required timing, two repair attempts repeat the same failure, or connector authority is insufficient. Save partial work and a minimal reproduction. A blocker does not erase successful changes. Do not reduce tolerances, disable failing tests, mark skipped tests passed, or downgrade a Must requirement without an accepted scope decision.

## Review AI output

Read the actual diff at the recorded commit. Check domain equations/signs/line semantics, transaction boundaries, cutoffs, index/constraint changes, exceptional paths, package additions, logs and secrets. Recompute a sample by hand or an independent fixture. Require a reviewer to state findings by severity with file/test evidence; “looks good” is not review. Fix critical/high issues before merge; medium risks have owner/disposition and cannot violate acceptance. Verify the corrected commit again, not the earlier one.

## Worktrees, integration and persistent state

For parallel tasks: `git worktree add -b task/FL-xxx ../footlens-FL-xxx <base-commit>` using an observed base hash; each gets a unique disposable database. Never share a writeable local database or generated migration output. Integration runs one PR at a time, rebases/merges against actual current main, re-runs affected/full stage checks, and records new commit. Conflicts are resolved semantically and reverified. Delete worktrees only after changes are committed/integrated and no untracked work remains.

State transitions: Ready→Claimed→Implementing→Verifying→Review→Done; failures may enter Repair or Blocked. Done requires merged commit plus acceptance evidence; runtime statuses live in PostgreSQL separately. State/project.json and task records update via compare-and-swap revision through one orchestrator. Handoff includes next action and exact command failures. Reconstruct progress from Git/CI if state disagrees, recording reconciliation.

## Finish each session

Return outcome, scope touched, test evidence, known limitations, diff/commit and next ready task. Update docs when contract changes. Produce no hidden reasoning transcript; give concise decisions and trade-offs. Never claim a deployment, successful model or complete feature from documentation alone.
