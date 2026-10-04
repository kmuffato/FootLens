# Verification strategy

## Test layers and independent evidence

Pure functions: numerical distributions, settlement, odds conversion, graph and temporal selection. Application tests: use-case failures, idempotency, readiness and immutable DTOs. PostgreSQL integration: real provider constraints, EF migrations, transactions/isolation, roles, JSON, leases and outbox. API contracts: auth, status/error schema, body limits and repeated keys. Windows desktop: presenters plus critical keyboard/DPI journeys. End-to-end: import→forecast→paper position→settlement→report→backup/restore. Statistical evaluation is its own layer, never inferred from unit-test success.

T01–T35 are acceptance suite families named in TASK_BREAKDOWN; each feature creates discoverable test cases beneath its family. Test names include a stable rule/requirement ID. Actual runner output, skipped count, commit and environment are evidence. CI rejects empty test discovery. Coverage percentages are diagnostics; gate critical rules and failure cases, not an arbitrary target that encourages trivial tests.

## Must-have adversarial tests

- Parser handles UTF8 BOM, quotes, multiline fields, truncated records, size limit, culture and invalid timezones.
- Alias ambiguity/correction and provider conflict cannot overwrite historical interpretation.
- Temporal perturbation changes future records and current aliases while earlier snapshot/forecast hashes remain fixed.
- Numerical tests compare analytic/high-precision fixtures, boundaries, recurrence, normalization, rare tails, gradient and failure domains. Do not copy production functions into expected-value code.
- Market properties: complements, categorical mass, DC sum2, monotone lines, BTTS bounds, halves sum FT, SOT support.
- Settlement truth table covers totals/handicaps ±whole/half/quarter, win/push/half outcomes, void and correction.
- Job crash at claim, compute, before commit, after commit/before ack; stale lease cannot write; consumer dedupe prevents duplicate effect.
- Ledger reserves simultaneous exposure without borrowing; exchange market commission and reversals reconcile cash+reserve.
- Migrated/restarted store preserves immutable objects; runtime roles deny mutation/truncate/DDL; source/diagnostic exports contain no secrets.

## Oracle fixtures and reproducibility

reference/golden-vectors.json supplies analytic examples, not complete legacy regression. Legacy fixtures must recover every input and rounding convention before being called parity tests. Extended special-function fixtures need source/tool/version/precision/licence and independent generation in an isolated oracle workflow; do not add a production numerical package merely for tests.

Tolerance policies: odds arithmetic decimal exact within declared scale; probabilities abs1e-12 with small-tail relative checks; normalized mass1e-10; matrix tail≤1e-9; empirical fit reproducibility within recorded optimizer tolerance; money reconciles at currency precision after explicit rounding. Cross-platform floating results may differ within tolerance. Record runtime/CPU/seed/data/code hashes.

## Release rehearsal

Use a clean Windows VM and clean PostgreSQL store, install release bundle, import synthetic licensed sample, complete UX journey, interrupt a job, resume, create backup, restore elsewhere, reproduce a saved forecast/report, upgrade from N-1 and test rollback plan. Separate live/private data from test artifacts. Performance tests use generated or licensed data with declared size and hardware, never undocumented anecdotal timing.

Required failures block the stage; optional environment failures are Blocked and the release remains blocked until evidence exists. Never replace PostgreSQL with SQLite to obtain a green integration check. Pack validation is explicitly not application validation.
