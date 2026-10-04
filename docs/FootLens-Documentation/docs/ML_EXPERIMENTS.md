# ML and model experiment protocol

“ML” includes statistical fitting; a neural-network runtime is not required. First candidate is the C# penalised DC model. An experiment must identify hypothesis, baseline, improvement/non-inferiority criterion, fixed feature definitions, data availability, cohorts, sample-size reasoning, compute budget, train/validation/test split, search space and stopping rule before execution.

Use templates/model-card.md and prompts/07-ml-experiment.md. Snapshot data and code, hash configuration and store every trial. Use nested chronological validation, with a final untouched holdout. Bootstrap or compare paired fixture scores. A model that improves training likelihood but loses out-of-sample proper scores is not promoted. Experiments with insufficient historic availability are exploratory and cannot become strict evidence by relabelling.

First experiment: independent Poisson versus penalised time-decayed DC, same league fixtures and eligibility; secondary objective calibration by draw and totals; primary multiclass Brier, log loss secondary. Search only declared H/κ grids. Epsilon choices, clipping counts, failed fits, fallback frequency, uncertainty success and runtime are report fields. Compare cold-start teams and low-coverage cohorts explicitly.

Later candidates (Elo features, xG, bivariate counts, ensembles) each need their own protocol and feature timing evidence. A Python oracle or research-only library may be admitted by dependency ADR; production inference remains C# unless an explicit ADR changes that boundary. Never download arbitrary executable models into the release pipeline. Fit artifacts are data with validated schema/hash, not deserialised executable objects.

Promotion: experiment finished → independent verifier checks splits/numerics → owner reviews model card and failure modes → append approval event for the exact hash → set readiness per league/market. Drift creates an alert and possible quarantine using predefined policy; it never automatically retrains and promotes a replacement. Rollback activates a prior approved artifact; historical predictions remain unchanged.
