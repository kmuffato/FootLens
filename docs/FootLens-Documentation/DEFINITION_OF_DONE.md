# Definition of Done

“Done” is a state backed by evidence for the exact merged/released artifact. Planned, implemented, tested, empirically validated and released are different states. Do not mark one from evidence of another.

## Feature DoD

- Stable requirement/task ID, bounded vertical behaviour and all acceptance criteria satisfied.
- Domain invariants and failure/unavailable states implemented; no silent scope loss or new dependency.
- Focused unit tests plus meaningful integration/contract tests; actual PostgreSQL for provider behaviour; Windows evidence for UI changes.
- Temporal, mathematical, monetary and idempotency tests where affected; no required skipped tests.
- Reviewer inspects exact final diff; critical/high findings resolved, remaining findings have accepted disposition.
- Relevant API/schema/UX/loop documentation and examples updated; migration path and rollback/restore assessed.
- Task evidence records command, exit code, environment, commit and artifact hashes; merge result reverified.
- No credentials, private source payload or generated build junk committed; task state updated only after merge.

## Model DoD

- Model card, hypothesis, supported domain, data definitions, assumptions, candidate grid and evaluation protocol frozen before test exposure.
- Training and calibration data eligibility demonstrable; Strict and Assumed evidence clearly separated; no-look-ahead perturbation tests pass.
- Numerical oracles, gradient/positivity/tail/convergence/coherence tests meet documented tolerances; fallback behaviour explicit.
- Cohort coverage/sample thresholds and preregistered proper-score/calibration gates satisfied for each enabled league/market, or model remains experimental.
- Every trial, failed fit, fallback, bootstrap seed/draw, calibration version and limitation retained.
- Baselines and paired uncertainty reported; ROI not substituted for probability validation.
- Approved artifact hash, readiness scope, reviewer and rollback version recorded; deployment reproduces approved inference within tolerance.

## Documentation DoD

- Required content is operational: contracts, examples, limits, error states, command prerequisites and acceptance ownership.
- Internal links resolve; identifiers and task dependencies valid; formulas/example arithmetic checked; machine schemas parse.
- Defaults versus confirmed constraints and future validation versus completed checks distinguished.
- Architecture/data/API/loop/roadmap/DoD agree; accepted ADRs explain deliberate departures.
- Source and dependency claims have dated primary references; no unsupported audit/performance claim.
- New reader can bootstrap one slice, use a prompt, run its verifier and hand off without retrieving chat history.

## Release DoD

- All v1.0 Must tasks accepted with traceability; unresolved blockers zero; explicit experimental market states visible.
- Locked SDK/packages/images, SBOM/licenses and source-data use rights reviewed; artifact hashes and signing/trust instructions included.
- Full test matrix and empirical gates recorded; actual tested binary/model/schema hashes match release manifest.
- Clean Windows installation, N-1 upgrade, migration, restart/resume, core UX, source-independent offline use and recovery rehearsed.
- Database+artifact backup restored in a separate instance and selected journal/report hashes verified; RPO/RTO measured against target.
- Secrets/permissions/network bindings/observability checked; operator and user guide, runbooks and known issues shipped.
- Deployment authority recorded; staged smoke passes before declaring production success; rollback decision path ready.
- Owner accepts release outcome; maintenance owner/schedule and project-closure checklist complete.

A failed mandatory check cannot be converted to NotApplicable to meet a deadline. A real scope change requires recorded owner decision, impact and revised version/milestone. “All tests passed” must name which suite and environment; it never means a model has proved profitable.
