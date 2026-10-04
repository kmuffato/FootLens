# Product requirements and assumptions

## Goal and release boundary

Deliver an inspectable football analytics workstation for personal use, initially validating the English Premier League and Championship independently. Multi-league identities are mandatory; a league is not called validated merely because it imports. Pre-match forecasts only. No guaranteed prediction accuracy or profitability, no automated bet placement, no in-play execution. All betting is simulated. The application must remain useful with CSV data and manual odds.

The release supports core goals first; extended market families follow through the same contracts. Public web UI, accounts, cloud synchronisation, mobile, live trading, neural networks and arbitrary accumulator pricing are deferred. A loopback API supports the desktop and scripted local workflows; it is not a public SaaS commitment.

## Assumptions and decisions

| ID | Default | Consequence / revisit trigger |
|---|---|---|
| A01 | Windows 11 x64 WinForms remains the primary UI | Preserve earlier workflow; revisit only on explicit UI scope change |
| A02 | Local ASP.NET Core service and private PostgreSQL | Service owns EF and scheduled jobs; three local processes including client |
| A03 | .NET 10 / EF 10 / Npgsql provider 10 / PostgreSQL 18 | Exact patches and SDK feature band resolved in bootstrap, then locked |
| A04 | One owner, en-GB and pt-BR UI, UTC storage | Resource files; odds and CSV parsing use declared culture; no implicit timezone |
| A05 | Own C# mathematical code; reviewed OSS infrastructure | Use EF/Npgsql and test infrastructure, avoid recreating DB/crypto/HTTP |
| A06 | Historical availability often unknown | Retrospective results labelled Assumed, separate from Strict evidence |
| A07 | Default UI request budget 2 seconds warm, 100k match/5m odds reference dataset | Targets measured in FL-031; queued fitting and backtests excluded |
| A08 | User initiates imports initially; schedules opt-in per source | Durable jobs enabled from foundation; no unlicensed automated feeds |
| A09 | No production repository or hosting supplied | Documentation and local deployment path provided; credentials injected later |
| A10 | At least 500 out-of-sample fixtures per validation league and 100 per enabled market cohort | Gate defaults, not proof of sufficient power; below threshold is experimental |
| A11 | Default 10,000-unit simulated bankroll, fixed 1-unit stakes | Stake limits and currencies are simulation parameters, not recommendations |
| A12 | Retain referenced evidence indefinitely unless a source-rights requirement demands removal | Removal quarantines dependent evidence and records the loss; no silent deletion |

## Functional requirements

| ID | Requirement and acceptance |
|---|---|
| R01 | Import canonical CSV/JSON with raw hash, provider, mapping and row diagnostics; duplicate content does not duplicate observations |
| R02 | Reviewed aliases for team, league, referee, bookmaker and provider market; ambiguous mapping quarantines affected rows |
| R03 | Strict cutoff selects only eligible historical revisions, including aliases and schedule; future mutation leaves past forecasts unchanged |
| R04 | All probabilities reference an immutable coherent distribution and lineage manifest committed before presentation |
| R05 | Odds support decimal/fractional/American input; preserve original price and settle exact rules/period/line |
| R06 | Explain implied probability, overround, de-vig assumptions, value delta and cost-aware expected payoff |
| R07 | Goal markets: 1X2, double chance, BTTS, correct score, totals, team totals, clean sheets and Asian lines pass common invariants |
| R08 | Halves/HT-FT allocation reconciles to FT; shots/SOT, corners, yellows, fouls and offsides are available only with valid coverage or named fallback |
| R09 | Historical and referee summaries show n, missingness and cutoff; source xG and predicted expected goals have different labels |
| R10 | Persist training inputs, model/config/calibration versions, code hash, probability mass and diagnostic state |
| R11 | Walk-forward backtests prove time ordering, retain all candidates, and report calibration plus uncertainty by cohort |
| R12 | Paper betting provides costs, price availability, stake limits, bankroll reservations, settlement and ledger corrections |
| R13 | Jobs survive restart, use idempotency keys, fencing and bounded retries; no duplicate forecast or ledger effect |
| R14 | Readiness/config/model approval states, evidence and audit history govern what is displayed as approved |
| R15 | Opt-in schedules, local alerts and calibration drift expose stale/failed workflows; no silent model promotion |
| R16 | Desktop offers eleven analysis workspaces plus an Operations workspace, keyboard access and honest unavailable states |
| R17 | Installation, migrations, backup/restore, upgrade and uninstall preserve owned data unless deletion is explicit |
| R18 | Development loops have task packets, state, path/connector budgets, evidence and an independent verifier |
| R19 | Legacy parity is isolated and labelled; archive all 620 Expected formulas' mapping before declaring complete migration |
| R20 | Versioned documentation, release evidence and ownership allow maintenance and project closure |

## Observable success

A user can reproduce a saved forecast from its exact evidence, explain why a market is unavailable, run a leak-resistant backtest, inspect a paper ledger and restore the store into a separate instance. Release v1.0 requires all Must tasks and DoD gates; market enablement still depends on data/validation. A disabled source-dependent market counts as honest functionality only if the documented acceptance explicitly allows that state; it never counts as a validated model.
