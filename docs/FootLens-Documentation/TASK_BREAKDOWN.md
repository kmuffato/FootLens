# Task breakdown

Implementation state: **all tasks NotStarted**. IDs are stable. Each task is one reviewable feature slice; split into child tasks if implementation exceeds its bounded packet, preserving parent acceptance. Suggested order follows dependencies, not blind numeric ordering. M7 is extension scope after v1.0.

## FL-001 — Bootstrap solution and verifier
Milestone M0 • Epic: Foundation • Must

As an implementer I can build and verify the selected stack from a clean checkout.

Dependencies: None. Requirements: R18.

Implementation tasks: Create projects/dependency rules; pin SDK/packages; CI restore/build/test commands; create authenticated skeleton and disposable PostgreSQL path.

**Acceptance:** Clean build passes; verifier exits nonzero for missing required suite; no app credentials in repository.

**Verification:** T01 build and negative verifier; T02 architecture boundary

## FL-002 — Initial EF schema and migrations
Milestone M0 • Epic: Persistence • Must

As an operator I can initialise and upgrade the database reproducibly.

Dependencies: FL-001. Requirements: R17.

Implementation tasks: Map core catalog/ingest/ops entities; generate migration; roles and constraints; fresh/N-1 migration harness.

**Acceptance:** Fresh Postgres schema matches required constraints; runtime cannot DDL; migration evidence stored.

**Verification:** T03 fresh DB / N-1 migration / constraint rejection

## FL-003 — Durable job and outbox foundation
Milestone M0 • Epic: Operations • Must

As a user my accepted work survives process restart.

Dependencies: FL-002. Requirements: R13, R18.

Implementation tasks: Implement queue/lease/fencing, attempt/checkpoint records, outbox/inbox and loop driver state schema.

**Acceptance:** Worker crash before/after commit has one effect; expired worker cannot commit; attempts bounded.

**Verification:** T04 kill-worker / duplicate delivery / stale lease

## FL-004 — Canonical match import
Milestone M1 • Epic: Ingestion • Must

As an analyst I can import matches with row-level provenance.

Dependencies: FL-002, FL-003. Requirements: R01.

Implementation tasks: Stream CSV/JSON; preview counts; hashes and chunks; activate only complete batches; canonical sample fixtures.

**Acceptance:** Quoted/newline/BOM import works; identical request idempotent; cancellation hides partial facts.

**Verification:** T05 bounded CSV, idempotency and partial batch

## FL-005 — Reviewed identities and aliases
Milestone M1 • Epic: Catalog • Must

As an analyst I can resolve source names without corrupting histories.

Dependencies: FL-004. Requirements: R02.

Implementation tasks: Canonical leagues/seasons/teams; team/referee/bookmaker/market alias registry; decision API and quarantine.

**Acceptance:** Ambiguous alias stays quarantined; reviewed remapping yields new version; old snapshots unchanged.

**Verification:** T06 alias ambiguity/correction/version

## FL-006 — As-of snapshots and data quality
Milestone M1 • Epic: Ingestion • Must

As an analyst I can reproduce what was knowable at a cutoff.

Dependencies: FL-005. Requirements: R03, R10.

Implementation tasks: Revision selector, source precedence, manifests, timing modes, metric DQ and hash canonicalization.

**Acceptance:** Future/late revisions cannot change prior snapshot; missing data remains unavailable; same semantic input hashes deterministically.

**Verification:** T07 no-look-ahead future-mutation suite

## FL-007 — Analytic Poisson baseline
Milestone M1 • Epic: Modeling • Must

As an analyst I can compute an explainable first score distribution.

Dependencies: FL-001, FL-006. Requirements: R04, R07.

Implementation tasks: Pure PMF/tails, matrix and projector; analytic fixture; baseline league rates with cold-start disclosure.

**Acceptance:** Analytic means1.2/.8 and complements pass; tails bounded; unsupported domain errors explicit.

**Verification:** T08 independent analytic/oracle vectors

## FL-008 — Immutable forecast journal
Milestone M1 • Epic: Forecasts • Must

As an analyst I can retrieve the exact forecast shown earlier.

Dependencies: FL-003, FL-006, FL-007. Requirements: R04, R10.

Implementation tasks: Persist distribution, prediction, projected markets and audit; fenced/idempotent creation; explain endpoint.

**Acceptance:** No probability displayed before commit; correction cannot update journal; request repeat resolves original result.

**Verification:** T09 append-only role/transaction/fencing

## FL-009 — Match Center vertical slice
Milestone M1 • Epic: Desktop • Must

As a user I can import/select a fixture and view its saved forecast.

Dependencies: FL-004, FL-008. Requirements: R16.

Implementation tasks: WinForms shell/presenter/API client; fixture context; loading/cancel/offline errors; number badges.

**Acceptance:** Keyboard import→fixture→journal journey succeeds; stale async response cannot overwrite selection.

**Verification:** T10 Windows journey and presenter cancellation

## FL-010 — Odds ingestion and normalization
Milestone M2 • Epic: Markets • Must

As an analyst I can compare complete compatible odds.

Dependencies: FL-005, FL-006. Requirements: R05, R06.

Implementation tasks: Formats conversion, group identity/freshness, proportional de-vig, manual entry and original text.

**Acceptance:** 2/3.3/4 yields exact139/132 book sum and66/139 home fair; incomplete groups rejected.

**Verification:** T11 odds vectors and semantic mismatch

## FL-011 — Legacy migration inventory
Milestone M2 • Epic: Legacy • Must

As an owner I can see what was preserved or deliberately changed.

Dependencies: FL-006, FL-007. Requirements: R19.

Implementation tasks: Recover frozen old assessment/formula inventory; map every Expected entry and all families; capture full golden inputs; label unsupported.

**Acceptance:** 620 Expected entries individually accounted for against actual source; parity claims only for complete fixtures; audit totals reconciled.

**Verification:** T12 coverage manifest/golden source provenance

## FL-012 — Dependency graph and invariant verifier
Milestone M2 • Epic: Markets • Must

As an analyst I get internally consistent derived markets.

Dependencies: FL-007, FL-010. Requirements: R07.

Implementation tasks: Typed DAG, stable topo execution, cache identities, failure propagation and hard/soft diagnostics.

**Acceptance:** Cycles rejected; double chance sums2; BTTS subset bounds and monotone totals pass; quote changes only invalidate price descendants.

**Verification:** T13 graph cycle/cache/invariant property suite

## FL-013 — Value and explanation workspace
Milestone M2 • Epic: Markets • Must

As an analyst I can inspect value delta and net payoff assumptions.

Dependencies: FL-008, FL-010, FL-012, FL-009. Requirements: R06.

Implementation tasks: Sign convention, costs/freshness checks, Odds and Value Lab UI, distributions and uncertainty placeholder state.

**Acceptance:** Delta/EV fixture correct; percent points distinct; incompatible lines cannot compare; unavailable bands labelled.

**Verification:** T14 value/cost arithmetic and UI semantics

## FL-014 — Settlement engine
Milestone M2 • Epic: Backtesting • Must

As a simulator I settle whole, half and quarter markets correctly.

Dependencies: FL-007, FL-010. Requirements: R07, R12.

Implementation tasks: Quarter-unit keys, win/push/half states, void/postponement rules, outcome evidence and correction events.

**Acceptance:** Over2.75 at3 is half-win; -0.25 draw half-loss; exhaustive partitions and correction reversal pass.

**Verification:** T15 settlement table/oracle

## FL-015 — Chronological replay
Milestone M3 • Epic: Backtesting • Must

As an analyst I run rolling tests without future information.

Dependencies: FL-006, FL-008, FL-014. Requirements: R11.

Implementation tasks: Frozen RunSpec, inner/outer splits, weekly refits, checkpoints, held-out labels and result export.

**Acceptance:** Future mutations leave prior decisions unchanged; cancelled/resumed run equals uninterrupted run; modes separate.

**Verification:** T16 rolling/replay/leakage/resume

## FL-016 — Paper ledger and staking
Milestone M3 • Epic: Backtesting • Must

As an analyst I simulate executable decisions and exposure.

Dependencies: FL-014, FL-015. Requirements: R12.

Implementation tasks: Fixed/proportional/fractional Kelly, price selection, simultaneous reservations, commission/liquidity/limits and reversals.

**Acceptance:** No borrowing unsettled winnings; same-time order invariant; exactly one logical ledger effect; all money reconciles.

**Verification:** T17 ledger/batch exposure/cost/reversal

## FL-017 — Time-decayed DC fitting
Milestone M3 • Epic: Modeling • Must

As an analyst I compare a fitted goal candidate with baseline.

Dependencies: FL-007, FL-015. Requirements: R07, R11.

Implementation tasks: Penalised fit/constraints/gradient, convergence and fallback diagnostics; versioned candidate search.

**Acceptance:** Independent gradient checks; τ positivity; failed fit does not replace approved model; no held-out tuning.

**Verification:** T18 fitting gradients/feasibility

## FL-018 — Coherent calibration and uncertainty
Milestone M3 • Epic: Modeling • Must

As an analyst I see calibrated probabilities with meaningful bands.

Dependencies: FL-017, FL-012. Requirements: R04, R11.

Implementation tasks: OOS atomic calibration,200-draw block bootstrap, mixture, quantiles and interval failure reporting.

**Acceptance:** All draws/mixture coherent;≥180 successful draws gate; count intervals distinct from probability bands.

**Verification:** T19 calibration/uncertainty/coherence

## FL-019 — Evaluation and reports
Milestone M3 • Epic: Backtesting • Must

As an owner I compare proper scores and conditional paper performance.

Dependencies: FL-015, FL-016, FL-018. Requirements: R11, R12.

Implementation tasks: Brier/logloss/reliability/ECE, paired intervals, ROI/drawdown/CLV, report artifacts and cohorts.

**Acceptance:** Hand-computed metric fixtures pass; empty cohorts null; reports expose assumptions, exclusions and all tried candidates.

**Verification:** T20 metric/report reconciliation

## FL-020 — Conditional periods
Milestone M4 • Epic: Modeling • Must

As a user I inspect half and HT/FT markets reconciled to FT.

Dependencies: FL-017, FL-018. Requirements: R08.

Implementation tasks: Period shares/prior, conditional allocation and HT/FT projection; coverage gates.

**Acceptance:** Summing allocations returns FT; unsupported halves unavailable; no half independence shortcut.

**Verification:** T21 period marginalization

## FL-021 — Secondary counts and SOT
Milestone M4 • Epic: Modeling • Must

As a user I inspect shots/SOT/corners/cards/fouls/offsides honestly.

Dependencies: FL-017, FL-018. Requirements: R08.

Implementation tasks: NB fit/convolution, Poisson fallback, binomial SOT thinning, referee shrinkage and definition registry.

**Acceptance:** SOT≤shots atoms; NB totals by convolution; each missing family independently unavailable with reasons.

**Verification:** T22 NB oracle/thinning/coverage

## FL-022 — Team league referee summaries
Milestone M4 • Epic: Statistics • Must

As a user I understand historical performance and source coverage.

Dependencies: FL-006, FL-009. Requirements: R09.

Implementation tasks: Team perspectives, unique samples, ranks/ties/points, referee histories, recorded-xG distinction.

**Acceptance:** Each fixture counted once; last-five overlap disclosed; n=0 unavailable; two league views independent.

**Verification:** T23 summary/tie/cutoff fixtures

## FL-023 — Complete analysis workspaces
Milestone M4 • Epic: Desktop • Must

As a user I navigate all specified analysis workflows.

Dependencies: FL-013, FL-019, FL-020, FL-021, FL-022. Requirements: R16.

Implementation tasks: Finish market ladders, model lab, journal, data manager, profiles/help; exports and explanatory drill-downs.

**Acceptance:** All11 analysis workspaces pass scripted journeys with loading/empty/partial/stale/error states.

**Verification:** T24 full Windows workflows/accessibility

## FL-024 — Approvals readiness and audit
Milestone M5 • Epic: Governance • Must

As an owner I control which artifacts are trusted and see changes.

Dependencies: FL-018, FL-019, FL-023. Requirements: R14.

Implementation tasks: Immutable config/calibration approval events, market lifecycle, audit browser and exact-hash promotion/rollback.

**Acceptance:** Unapproved hash blocked; failed cohort quarantined independently; old forecast retains old approved artifact.

**Verification:** T25 lifecycle/optimistic conflict/audit

## FL-025 — Schedules drift and alerts
Milestone M5 • Epic: Operations • Must

As an owner I learn when data or model quality deteriorates.

Dependencies: FL-003, FL-019, FL-024. Requirements: R15.

Implementation tasks: Opt-in source schedules, coalescing/DST rules, stale data/job/disk alerts, rolling calibration drift.

**Acceptance:** Restart coalesces missed work; dedupe alerts; drift cannot self-promote; small sample yields insufficient evidence.

**Verification:** T26 scheduler/time/drift/dedup

## FL-026 — Backup restore and retention
Milestone M5 • Epic: Operations • Must

As an owner I can recover evidence and safely prune cache.

Dependencies: FL-024. Requirements: R17.

Implementation tasks: Database/artifact backup manifest, off-host encrypted option, restore drill and referenced-object retention graph.

**Acceptance:** Fresh restore reproduces selected prediction/report; pruning cannot delete referenced payload; licence deletion marks dependent claims.

**Verification:** T27 backup/restore/hash/retention

## FL-027 — Security and dependency hardening
Milestone M5 • Epic: Security • Must

As an owner I can run privately with controlled permissions.

Dependencies: FL-010, FL-024. Requirements: R17, R18.

Implementation tasks: Auth/secrets/ACLs/source allowlist, import limits, export escaping, SBOM and dependency lock review.

**Acceptance:** No secret in diagnostics; unauthorized API denied; runtime cannot mutate immutable tables/DDL; malicious input tests pass.

**Verification:** T28 security/threat/dependency

## FL-028 — Packaging and migrations
Milestone M6 • Epic: Release • Must

As an owner I install and upgrade a verifiable personal release.

Dependencies: FL-023, FL-025, FL-026, FL-027. Requirements: R17.

Implementation tasks: Windows publish/service/client package, PostgreSQL setup, migration bundle, manifests and clean-machine smoke.

**Acceptance:** Fresh install and N-1 upgrade run core journey; backup verified before migration; rollback/restore rehearsed.

**Verification:** T29 clean installation/upgrade/recovery

## FL-029 — Multi-league empirical validation
Milestone M6 • Epic: Validation • Must

As an owner I can distinguish validated from experimental markets.

Dependencies: FL-019, FL-020, FL-021, FL-024. Requirements: R08, R11, R14.

Implementation tasks: Freeze cohorts/holdout, run evaluation and model cards for at least2 leagues, inspect coverage/calibration/fallbacks.

**Acceptance:** Per-cohort promotion criteria met or candidate stays experimental; no unsupported blanket accuracy claim.

**Verification:** T30 registered statistical evaluation

## FL-030 — Accessibility and localization
Milestone M6 • Epic: Desktop • Must

As a user I operate with keyboard and my display culture.

Dependencies: FL-023, FL-028. Requirements: R16.

Implementation tasks: en-GB/pt-BR resources, DPI/high contrast, numeric tables for charts and offline/reconnect testing.

**Acceptance:** 100/125/150/200%DPI and keyboard journeys pass; invariant storage unaffected by comma decimals.

**Verification:** T31 UX/DPI/culture

## FL-031 — Performance and release verification
Milestone M6 • Epic: Quality • Must

As an owner I know the supported workload and remaining limits.

Dependencies: FL-025, FL-028, FL-029, FL-030. Requirements: R17, R20.

Implementation tasks: Benchmark reference dataset/hardware, query plans/resource caps, full regression and release evidence.

**Acceptance:** Targets met or explicit accepted scoped limit; no skipped Must gate; release hash matches tested artifacts.

**Verification:** T32 load/cancellation/full release

## FL-032 — Handover and finish v1.0
Milestone M6 • Epic: Closure • Must

As an owner I can operate the finished project without chat history.

Dependencies: FL-011, FL-031. Requirements: R20.

Implementation tasks: Complete user/operator docs, release notes, known issues, maintenance calendar, inventory and signed closure checklist.

**Acceptance:** All Must tasks traced to merged/tested evidence; clean checkout/runbook rehearsal succeeds; owner acceptance recorded.

**Verification:** T33 closure audit and handover

## FL-033 — Advanced de-vig methods
Milestone M7 • Epic: Extension • Should

As an analyst I can compare justified margin-removal assumptions.

Dependencies: FL-010, FL-019. Requirements: R06.

Implementation tasks: Power/odds-ratio and optionally Shin only with full numerical specification/oracles; sensitivity report.

**Acceptance:** Feasible roots/tails and input failures tested; methods clearly labelled; old snapshots unaffected.

**Verification:** T34 de-vig numerical fixture

## FL-034 — Additional ML and source adapters
Milestone M7 • Epic: Extension • Should

As an owner I extend data/models without destabilising baseline.

Dependencies: FL-024, FL-029. Requirements: R01, R11.

Implementation tasks: New source admission or candidate protocol, licence/timing evidence, isolated experiment and review.

**Acceptance:** No adapter auto-enabled without rights; no model promoted without same evaluation gates.

**Verification:** T35 adapter/model extension contracts
