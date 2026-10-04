# Complete roadmap

Duration is measured by passed gates, not generated lines or agent hours. Indicative focused delivery ranges assume one experienced owner with AI assistance, usable data and a working Windows/PostgreSQL environment. They are planning estimates, not commitments; custom numerics and missing historical evidence are primary schedule risks.

| Milestone | Outcome | Task IDs | Indicative effort | Exit evidence |
|---|---|---|---|---|
| M0 | Reproducible build, DB and resumable work | 001–003 | 1–2 weeks | build/migration/lease failure tests |
| M1 | First usable import→fixture→saved forecast desktop | 004–009 | 2–3 weeks | one complete vertical journey and future-mutation test |
| M2 | Odds/value, market invariants, settlement, legacy inventory | 010–014 | 2–3 weeks | exact odds and quarter-line oracles; traceable legacy source |
| M3 | Replay, ledger, fitted goals, calibration and reports | 015–019 | 3–5 weeks | leak tests, proper scores, reproducible ledger/report |
| M4 | Halves, secondary markets and full analysis UI | 020–023 | 3–5 weeks | family coherence, coverage and11-workspace journeys |
| M5 | Governance, scheduling, recovery and security | 024–027 | 2–3 weeks | quarantine/promotion, restore and alert evidence |
| M6 | Validated personal release and closure | 028–032 | 2–3 weeks | clean install/upgrade, multi-league evaluation, owner acceptance |
| M7 | Optional extensions | 033–034 | scoped separately | independent ADR/protocol and same gates |

The initial working product is M1, not completion of all research. v1.0 finishes M6 and all Must tasks; an advanced candidate may stay experimental while a validated baseline remains active. Source-dependent extended markets may be explicitly unavailable where coverage fails, but enabling/validation claims require evidence. Core user journeys, engine correctness and recovery cannot be waived by calling them unavailable.

## Critical path and useful parallelism

Foundation→temporal data→journal/Poisson→settlement/replay→calibration/evaluation→governance→release. Desktop can progress against frozen API fixtures; statistical summaries can progress once snapshot contracts stabilize. Odds import can progress alongside legacy inventory. Parallel work always uses separate worktrees, test stores and agreed file ownership; migrations stay serialized. Do not run parallel agents on the same formula or schema to manufacture throughput.

## Gates and replanning

M0 locks exact stack and scripts. M1 proves the architecture by a real vertical slice. M2 fixes mathematical/rules contracts before simulated money. M3 must expose every timing/cost assumption. M4 cannot hide missing period/stat coverage. M5 rehearses recovery. M6 freezes code/schema/model/config, runs full acceptance and packages evidence. A failed statistical candidate does not hold the whole application hostage: retain the validated baseline and document experimental status. A failed numerical or temporal correctness gate blocks the affected release functionality.

After every milestone: owner reviews outcome/evidence, refreshes risk register and selects next bounded tasks. Ordinary implementation proceeds under this plan; do not create an extra approval ritual per file or prompt. Scope changes require a decision record and revised acceptance, never quiet task deletion.
