# Model specification and numerical implementation

## Models admitted in order

1. Analytic/league-frequency benchmarks and independent Poisson (M1/M2).
2. Legacy parity adapter for explicitly captured inputs; never the default production probability engine.
3. Penalised time-decayed Dixon–Coles goal candidate, coherent periods and calibration (M3).
4. Secondary count families and shots/SOT (M4).
5. Further ML candidates only through the experiment loop, not release blockers for v1.0.

Each league fits separately. ModelVersion binds data snapshot, code, ordering of parameters, fit settings, diagnostics, seed, training end and availability policy. Stronger defence d reduces the opponent log rate:

ηH=μ+h+a_home-d_away+xHβ; ηA=μ+a_away-d_home+xAβ; λ=exp(η).

Constrain sum attack=sum defence=0 by storing T-1 free values and reconstructing the last. Weight fixture m by exp(-ln2*ageDays/H). Initial H=240 days; inner-validation grid {60,120,240,480}. Penalise squared team effects with κ∈{.1,1,10,100}; no tuned choice may use test outcomes. Metadata records all candidates, not just the winner. No untimestamped context covariates in the fitted default; manual scenarios are separate assumption profiles.

Dixon–Coles multiplies independent goal mass by τ00=1-λHλAρ, τ01=1+λHρ, τ10=1+λAρ, τ11=1-ρ, and 1 elsewhere. All four must be positive for every fitted/predicted fixture. Fit weighted log likelihood plus penalty. No negative-mass clipping. If an approved fit is infeasible for a new fixture, use the approved independent-Poisson fallback with its own identity and reason; otherwise unavailable.

Own-code BFGS starts from penalised Poisson with ρ=0. Armijo c1=1e-4, step shrink=.5, max40 trials; reject infeasible steps. Up to1000 iterations; convergence requires scaled gradient infinity norm≤1e-6 and relative objective change≤1e-8 on three accepted steps. Stagnation with large gradient is failed fit. Store boundary hits and objective trace. Central finite differences at h=1e-5(1+|θ|), h/2 and 2h validate analytic gradients. Never invert a Hessian to solve a linear system.

## Secondary counts and periods

NB2 mass=Γ(k+r)/(Γ(r)Γ(k+1))*(r/(r+μ))^r*(μ/(r+μ))^k; variance=μ+μ²/r. Fit per league/statistic with log-rate effects and r in [.05,1e6]. Method of moments r=μ²/(s²-μ) is an initializer only for s²>μ. If evidence does not justify overdispersion, retain Poisson. Convolve team distributions to derive totals: two arbitrary NB marginals do not sum to another NB with a guessed shape.

SOT conditional on shots S follows Binomial(S,θ), with beta-prior-smoothed accuracy; prior strength candidates10,30,100 shots are tuned chronologically. Enforce 0≤SOT≤S by construction. Goals remain a separate DC family: own goals/provider definitions make a universal goals≤SOT constraint invalid.

Given FT count G, first-half K|G follows Binomial(G,f); second-half=G-K. Estimate f from eligible period observations with a beta prior equivalent to20 goals. This recovers FT exactly and supports HT/FT queries. It is a modelling assumption, not independent-half fitting. If valid period observations or an approved prior do not exist, half markets remain unavailable. Same construction for secondary periods only with compatible definitions.

Within each family use one joint; cross-family dependence is not fitted in v1. Do not offer combined-event odds from the product-family working assumption. Referee card effects are shrunk toward league baseline and require as-of assignments; missing referee is a neutral effect with disclosure. Context multipliers in the old sheet are legacy-only until independently validated.

## Calibration and readiness

Calibration fits only out-of-sample predictions generated inside training/validation history. Atomic temperature scaling uses p'_a proportional to exp(log(p_a)/T), T∈[.5,2]; include the same supported atomic space/tail policy. T=1 disables calibration. Recompute every related market after calibration. Separate binary calibrators may be used in diagnostic comparisons but never overwrite headline events and break identities. Record support sensitivity; material calibration changes require re-running the consistency suite.

States per league/market/model version: Disabled → Quarantined → Enabled, or Enabled ↔ Degraded; Quarantined blocks new approved predictions. Enabling requires DQ/coverage evidence, numerical tests and preregistered chronological evaluation. Config and calibration versions are Draft → Approved → Deprecated; approved payloads are immutable, deprecation does not rewrite prior snapshots. A new promoted model leaves the prior model available for rollback.

Default statistical gate: two leagues with≥500 OOS fixtures each and≥100 per enabled market cohort; multiclass Brier and log loss compared with fixed baselines, calibration/reliability with uncertainty. Non-inferiority Brier tolerance .005: paired fixture-block bootstrap upper95% bound of candidate-minus-baseline≤.005. Require no material leakage, numeric or calibration defect. Any stronger improvement claim requires its own prespecified criterion. Failing promotion keeps the validated baseline; it never removes the candidate's experiment evidence. These are chosen project gates, not measured performance.

## Numerical code and limits

Implement log-PMFs, stable recurrences, compensated sums, scalar brackets and linear solves in FootLens.Numerics. Reuse .NET Math and standard cryptography. Poisson λ∈[0,1000], k≤10000; goal forecasts λ≤50 and support≤256 per axis. NB/secondary support≤2048 and convolution≤1m operations. Probability error target abs1e-12 and rel1e-9 for p≥1e-10; normalized mass error≤1e-10. These need oracle evidence before release.

Poisson recurrence p(k+1)=p(k)λ/(k+1); NB recurrence p(k+1)=p(k)*(k+r)/(k+1)*μ/(r+μ). Initialise near mode in log space to avoid underflow at large λ. Evaluate small survival tails directly, not always 1-CDF. Sum until certified remaining tail≤1e-9; if geometric bound is used, prove its ratio upper bound<1. Γ expressions use tested log-gamma or finite-product ratios where cancellation matters. Algorithms, coefficients and independently generated high-precision fixtures require provenance in the numerical review.

PRNG algorithm/version, seed and draw order are part of artifact identity. Reproducibility means deterministic within the locked runtime/platform; cross-platform fits must meet tolerance rather than pretending bitwise equivalence. Bounded resource failures carry explicit error codes. Custom numerics are a maintenance cost: if safe accurate implementation proves disproportionate, submit a focused OSS dependency ADR with licence/version/evidence rather than silently lowering tolerances.

## Calibration support and tail certification

Temperature scaling can increase tail mass, particularly T>1. The uncalibrated omitted-mass bound alone is not a calibrated bound. Extend/evaluate the transformed atomic weights with a proven tail envelope (Poisson/NB recurrence ratios raised to1/T where applicable), bound the transformed omitted sum, divide by a lower bound on the normalizing constant, and require calibrated omitted mass≤1e-9. Re-run this for every parameter draw. If the required bound cannot be certified inside support/resource limits, return CalibrationTailUncertified and use only an approved T=1 fallback; never silently assume the pre-calibration bound still applies. An aggregate tail atom cannot answer exact score/subset events, so it is not an alternative to certification for those markets.
