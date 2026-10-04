# Backtesting and paper-betting engine

## Objective and immutable run specification

Estimate out-of-sample forecast quality and behaviour of a fully specified paper strategy. Prediction accuracy, probability calibration and betting profitability are different results. Each run fixes league/season scope, availability policy, training/calibration/test windows, features, model candidates, tuning grid, refit cadence, market/rules universe, executable-price policy, costs, selection rule, staking, seed and code commit before exposing test outcomes. RunSpec is immutable and hashed. If it changes after results are inspected, create a new exploratory run.

Strict replay only uses records proven available by decision time. Assumed-retrospective replay uses a named documented lag and is reported separately; unknown historical odds availability prevents executable-price/profitability claims. Legacy stored predictions without generated-at proof may be descriptive only. Outcome availability uses actual publication/known-at time, not scheduled kickoff alone.

## Rolling-window methodology

Default per league: up to730 days training, next90 days validation/calibration, following30 days outer test; advance30 days. Minimum365 training days; otherwise InsufficientHistory. Inner chronological folds choose half-life/penalty/calibration using only training and validation as specified. Fit calibration on OOS forecasts from within the pre-test history, never in-sample predictions or outer outcomes. At each 30-day origin select hyperparameters; refit team strengths weekly within the test block using only outcomes already available, with hyperparameters fixed. A fixed-origin comparison may be reported separately.

For each target fixture choose DecisionTime=scheduled kickoff known then minus60 minutes. Freeze that fixture revision and exclude all results not completed/available before DecisionTime. Postponement cancels stale scheduled decisions and creates new ones under the rules; if a paper position exists, settlement follows its bookmaker postponement policy. Same-time fixtures form a batch: size all bets from pre-batch equity/available cash, then reserve exposure atomically. Never let arbitrary row order access a later settlement.

Create outcomes on a distinct later timeline. Embargo any sample whose target/event completion overlaps a training/calibration boundary; day-level datasets use conservative next-day eligibility with a visible assumption. Features and normalisation fit separately per fold. Keep the final holdout sealed until the candidate, selection rules and report are frozen. Do not repeatedly tune on a “final” test season.

## Avoiding look-ahead: required tests

- Mutate future results, future odds, future aliases and late corrections: earlier predictions and selections are unchanged.
- Shuffle CSV row order and re-run: canonical snapshots and results remain equal within declared tolerance.
- Same-day fixture completing after decision time is excluded even if its matchweek is smaller.
- Injuries/referee/weather without historic available-at evidence are excluded from strict features.
- Closing odds are evaluation benchmarks only when captured after selection; never a predictor for that selection.
- Feature scaling, imputation, team priors and hyperparameters fit on permitted history only.
- Backdated provider timestamps without trustworthy provenance remain Assumed, not Strict.
- Test-set outcomes cannot be read through the fit/signal ports; enforce by fixture membership, not a comment in a prompt.

## Paper execution and settlement

Select only pre-recorded eligible quotes; default maximum quote age15m, finite positive stake capacity, permitted book, complete rules and market readiness Enabled. Selection default is model ValueDelta≥.03 AND net EV>0, one selection per fixture per strategy, with deterministic best-EV then market-key tie-breaking. This rule is an experimental default, not a recommended strategy. Store every rejected candidate and reason to expose selection bias.

Order of operations: release settlements known at t; compute pre-batch equity; generate proposals; apply exposure/stake/liquidity caps pro-rata across simultaneous proposals; round stake down to declared currency precision; reserve cash; persist decisions and ledger entries; later settle and release reserve. Bets cannot borrow unsettled winnings. Equity=cash+reserved stake valued at cost until settlement; report mark-to-market separately if ever implemented. One currency per run; no guessed historical FX.

Stake models:

| Model | Rule | Constraints |
|---|---|---|
| Fixed | 1 unit | Default; minimum stake and available balance |
| Proportional | .5% of pre-batch equity | Max1% per position,3% per fixture,10% total open exposure |
| Fractional Kelly | .25*max(0,(p*o-1)/(o-1)) | Binary/no push only; same caps, optionally use p05 |
| Settlement-aware Kelly | maximize sum_j p_j log(1+f*r_j) | Bounded scalar solve f∈[0,.01]; all wealth factors>0; unavailable if unsupported |

No independent full-Kelly sizing for correlated selections. Default one-per-fixture reduces but does not eliminate correlation; cap open exposure across all fixtures. Stake policies are versioned. Bust means no new position; do not reset bankroll invisibly. Record turnover (accepted stakes), reserved amounts, profit/loss, voids and push counts separately.

Execution costs include commission basis, fixed fees if supplied, odds deterioration, liquidity/stake-limit assumptions and rejected prices. Unknown historical liquidity is AssumedExecution, with sensitivity scenarios rather than a claim of attainable profit. Exchange commission groups by exchange/fixture/market/currency before applying charge to positive net market profit. Corrected results append reversing ledger entries and resettlement; never edit settled entries. Duplicate outcome delivery produces no duplicate effects.

## Metrics and reporting

Multiclass Brier=sum_k(p_k-y_k)^2 averaged over fixtures (no divide-by-K convention); binary Brier=(p-y)^2. Log loss=-log(p_outcome); use epsilon1e-15 only for metric computation, count clipped events and keep raw forecasts. Report proper scores alongside naive/league and market baselines under identical cohorts. ECE uses10 equal-width bins with n, mean p and observed rate; empty bins are missing, not0. Brier decomposition is optional with declared estimator. Sharpness has no meaning without calibration.

ROI=sum net profit/sum accepted stake; yield uses this same convention and must be labelled if an alternative is used. Return on starting bankroll is separate. Max drawdown=max_t((peakEquity_t-equity_t)/peakEquity_t), with event-order convention and cost-valued reserves. CLV price ratio=oddsTaken/closingOdds-1 only for identical contract and comparable book; also report difference of de-vig probabilities with explicit sign (closing minus taken). Missing closing evidence stays missing.

Resample whole fixtures in moving chronological blocks for95% metric/profit intervals; preserve all bets from a fixture and regenerate the chronological wealth path for drawdown sensitivity. Never resample correlated bets independently. Paired model comparisons use the same resampled fixtures. Default1000 metric bootstrap replicates, independent from parameter-bootstrap counts. Report sample size, effective coverage, failed replicates, seasonal dependence and selection/tuning count. Historical positive ROI may reflect variance, stale/unattainable prices, omitted costs, overfit strategy or a changed market; it is not a profit forecast.

Report exports: `run.json` metadata; `folds.csv`; `predictions.csv`; `candidates.csv` including rejections; `positions.csv`; `ledger.csv`; `metrics.json`; `calibration.csv`; `report.md`. Required dimensions: league, season, market, probability band, model/config version, availability mode and execution assumption. No averaging Strict and Assumed into one unqualified headline. Template in templates/backtest-report.md.

## Pseudocode

```text
freeze RunSpec and input evidence
for outer origin in chronological order:
  build eligible inner folds and tune without outer labels
  for event-time batch in test window:
    apply outcomes known by time and append ledger effects
    if weekly refit due: fit using only eligible observations
    freeze inputs; create and persist forecasts
    compare allowed prices; reserve accepted paper stakes
  attach later settlements without altering original forecasts
compute paired scores, calibration, financial and sensitivity reports
verify no-look-ahead, idempotency and reconciliation; freeze report hashes
```

Cancellation preserves completed checkpoints; resume only with identical spec and artifact hashes. An incomplete replay cannot be reported as a finished performance result. A replay run never modifies the live approved configuration or readiness registry.
