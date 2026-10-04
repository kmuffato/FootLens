# FootLens user guide

This guide describes the intended v1.0 workflows. Until the release gates pass, the application is not represented as delivered.

## First analysis

Start the local service/database, then Desktop. In Data Manager choose source/mapping and preview a CSV. Inspect unresolved aliases and invalid rows; approve mappings only when identity is clear. Activate accepted data and check coverage. Select league/season/fixture in Match Center. Choose an approved profile and cutoff. Request forecast; progress shows the durable job. Numbers appear after journal persistence; note prediction ID, model, timing mode and readiness.

EXP is a predicted mean count, not a guaranteed minimum. PROB is a probability from a named model distribution; FREQ is an observed historical rate with sample size. Parameter bands describe uncertainty in estimation under their method; count percentiles describe possible outcomes. A high probability does not imply favourable odds.

## Odds and markets

In Odds and Value Lab enter original decimal/fractional/American prices for one compatible market group. Confirm book, capture time, period, line and rules. Compare raw implied, proportional fair and model probability. Positive delta means the model is higher; net EV uses executable odds and costs. Stale/incomplete/mismatched prices cannot support a valid comparison. In Market Ladders inspect push and quarter-line outcomes; Under3.0 differs from Under2.5 because of the push at3.

## Evaluation

Use Model Lab to select a completed chronological backtest. Read data availability/execution assumptions, sample size, calibration/proper scores and candidate history before paper ROI. Inspect paper positions/ledger for rejected quotes, exposure, costs and corrections. No screen submits real bets. Unsupported markets show reasons; missing source data is not zero.

## Saved work and operations

Prediction Journal reproduces original versions and shows later outcomes separately. Changing a profile creates a draft; approve exact versions through Settings/Governance workflow after evidence review. Operations shows schedules (initially off), stuck jobs, alerts, audit and last verified backup. Retry only after reading its reason; a corrected source does not rewrite past predictions. Use export for a reproducible report and the operator backup procedure for recovery.

If offline, saved records may remain viewable but new server computations need local service/database. For error reports include correlation ID, release/model/config version and a synthetic reproduction; exclude passwords, API tokens and private raw data unless explicitly intended.
