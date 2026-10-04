# Probability engine

## Contract and terminology

Input: an immutable DataSnapshot, approved ModelVersion and ConfigVersion, fixture revision, AsOfUtc and optional exact OddsMarketSnapshot. Output: a ForecastSnapshot with typed probabilities, parameter uncertainty, predictive counts, numerical error bound, readiness and lineage. Probability values use double internally; money/odds use decimal; display rounding never feeds calculations. Reject NaN/infinity, odds≤1, ambiguous market keys and unsupported rules.

Distinguish OBS (source observation), SUM (summary), EXP (expected count), PROB (model probability), FREQ (historical frequency), VER (outcome verification), RULE (threshold signal). Historical xG is OBS; forecast mean goals is EXP. Unavailable is null plus a reason, never zero. Same number formatting does not make these quantities interchangeable.

## Implied probability, overround and fair probability

For complete mutually exclusive and exhaustive selections i at decimal odds o_i:

\[
q_i=1/o_i,\quad Q=\sum_i q_i,\quad O=Q-1,\quad p_i^{market}=q_i/Q.
\]

Report Q as book percentage (e.g. 105.15%) and O as overround (5.15 percentage points); never call Q itself the margin. Proportional de-vig is a convention, not proof of the bookmaker's fair probabilities. Default complete 1X2 example:

| Selection | Decimal odds | Implied probability | Proportional fair probability |
|---|---:|---:|---:|
| Home | 2.00 | 0.500000 | 0.474820 |
| Draw | 3.30 | 0.303030 | 0.287770 |
| Away | 4.00 | 0.250000 | 0.237410 |

Exact normalised values are 66/139, 40/139 and 33/139; rounded table values must sum within rounding tolerance. Q=139/132=1.053030303 and O=7/132=0.053030303. The machine fixture retains these exact fractions and the table is rounded only for display.

Use one bookmaker/exchange, fixture, period, line, rule version and a single capture group; time spread≤60 seconds default and price age≤15 minutes for a current comparison. These are configurable freshness policies. Mixed best prices are shown as a comparison basket, not one bookmaker's overround. Incomplete markets return IncompleteMarket. An underround is flagged, not rejected or automatically called arbitrage (prices/rules/stakes may differ).

Fractional a/b becomes 1+a/b, b>0 and a>0. American +A becomes 1+A/100; -A becomes 1+100/|A|, |A|≥100 by canonical input convention. Preserve original text, format and conversion version. Decimal odds are canonical. Exchange quotes must include commission basis and liquidity assumptions.

Additional de-vig methods are later reviewed extensions, not required for M2: power solves sum(q_i^k)=1; odds-ratio solves a common odds multiplier. Both require feasible bracket, convergence and comparison tests. No Shin algorithm is promised until its exact implementation/oracle contract is admitted. This intentionally narrows the old multi-method requirement for the first usable release; advanced methods are FL-033.

## Model distribution and event queries

Baseline independent Poisson: P(X=k)=exp(-λ)λ^k/k!. Fit improvements are specified in docs/MODEL_SPECIFICATION.md. For team scores H,A, π(h,a) is a single normalized distribution. Derived events:

- Home: h>a; Draw: h=a; Away: h<a.
- 1X=Home+Draw; X2=Draw+Away; 12=Home+Away. Their sum is 2, not 1.
- BTTS=Σ(h≥1,a≥1)π; No=1-Yes.
- Over2.5=Σ(h+a≥3)π; Under2.5=Σ(h+a≤2)π.
- Team clean sheet uses opponent goals=0; WinToNil additionally requires team goals>0.
- Correct-score mode is the largest atomic probability, with deterministic full-precision ties. Its probability is the mass itself, not 1 minus that mass.

Poisson unit fixture: λH=1.2, λA=0.8. Total mean=2.0; P(0,0)=exp(-2); P(Over2.5)=1-5exp(-2); P(BTTS)=(1-exp(-1.2))(1-exp(-0.8)). These analytic expressions are independent test oracles. Distribution tails extend until omitted mass≤1e-9, store actual bound and renormalisation. Max support=256 per goals axis; exceeding capacity returns ResourceLimit, never an undocumented cap.

## Settlement and expected payoff

Represent line in quarter units as integer LineQuarter (Over2.75=11); no floating equality. Period and rules distinguish regulation, added time, extra time, abandoned fixtures and cards definitions. Default football markets cover regulation including stoppage time, excluding extra time; source contract must agree.

For unit stake decimal odds o, outcome net returns are: win o-1, half-win (o-1)/2, push 0, half-loss -1/2, loss -1. Quarter lines split evenly into adjacent half-step contracts. Over2.75 splits Over2.5/Over3.0: at exactly 3 goals half wins and half pushes, giving half-win. Under2.75 at 3 is half-loss. Home handicap -0.25 splits 0 and -0.5: draw is half-loss. Cancellation/void refunds the reserved stake and is tracked separately from a sporting push.

\[
EV=p_W(o-1)+p_{HW}(o-1)/2-p_{HL}/2-p_L.
\]

Partition probabilities sum to one including push. Binary EV=p_model·o-1 applies only to no-push contracts. For pushes there is no unconditional fair win probability 1/o: break-even o=1+p_L/p_W for a simple win/push/loss contract, if p_W>0. Half outcomes use effective winning/losing stake fractions in the same ratio.

Commission: per-bet positive-profit commission c gives win return (o-1)(1-c); do not charge on returned stake or losses. Exchange market-level commission is charged on max(0, total net profit for that market) after aggregation, not independently per winning selection. Backtest cost mode must identify which rule is used. For binary p=.52, odds2.00, c=.02 on positive returns: EV=.52*.98-.48=.0296 per unit; gross EV=.04.

## Value delta and consistency

ValueDelta=p_model-p_marketFair; positive means the model assigns more mass. ValueDeltaPctPoints=100*ValueDelta. Distinguish delta from EV at executable odds, market disagreement and realised profit. With the exact 1X2 example and model home=.52: delta=.52-66/139≈.045179856 (4.518 percentage points), gross EV=.04. Fair market uncertainty and quote freshness can invalidate the comparison.

Mandatory invariant examples:

| Rule | Example / severity |
|---|---|
| p finite in [0,1]; categorical mass≈1 | No clipping negative model probabilities; hard failure |
| P(1)+P(X)+P(2)=1 | Absolute tolerance 1e-10 after normalisation |
| P(1X)=P(1)+P(X), sum DC=2 | Hard model-output invariant |
| Over2.5≤Over1.5; Under2.5=1-Over2.5 | Hard monotonic/complement invariant |
| BTTS≤P(H≥1), BTTS≤P(A≥1), BTTS≤Over1.5 | Hard event-subset inequalities |
| max(0,pH+pA-1)≤BTTS≤min(pH,pA) | Fréchet bounds; independence is not implied |
| Team clean sheet=opponent-zero probability | Both queried from same π |
| HT counts+second-half counts=FT in every atom | No multiplying independent half forecasts |
| SOT≤shots in every atomic state | Thinning construction, not post-hoc clamping |
| Asian settlement partition=1 | Includes push and half outcomes |

Model output checks are exact within numerical tolerance. Bookmaker market differences are soft diagnostics: margins differ, quote times differ and definitions differ. Compare normalized marginal bounds only after provenance checks; never “repair” bookmaker prices to match the model. A goal/corner combination cannot be priced by multiplying marginals without an explicit unvalidated dependence assumption, so accumulator pricing remains unavailable.

## Uncertainty bands

Separate event randomness (predictive count intervals), parameter uncertainty (interval for p), finite-sample calibration uncertainty and numerical truncation. Generate B=200 moving-block bootstrap fits by default, preserving chronological blocks and whole fixtures; rerun fitting and approved calibration for each draw using eligible data only. Block length defaults to 4 weeks, prespecified. Require≥180 successful draws; otherwise return IntervalUnavailable with failure count. Budget may queue this offline. Seeds, indices, fit failures and versions persist.

For event E, calculate p_b(E) for each accepted draw. Display median/mean as explicitly labelled, 5th/95th percentile parameter band; primary coherent point distribution is the arithmetic mixture of full distributions, then derive events. Bands for different events need not sum to one, although every draw must satisfy identities. They are sensitivity/estimation intervals under the resampling method, not a guarantee that the true chance lies within them. For value against fixed price probability q, the band is [p05-q,p95-q]; uncertain prices require a separately declared price sensitivity range.

Prediction count P10/P50/P90 comes from mixture CDF and is a different output. New teams get a league prior and disclosed wide uncertainty; absent source coverage remains unavailable. Deterministic output records numerical bound separately. No CI or API advertises “95% confidence” without its method, sample count and meaning.

## C# boundaries and errors

Use immutable records and CancellationToken for I/O and long computation. `IProbabilityEngine.Build(ModelArtifact, FeatureSnapshot, NumericalBudget)` returns DistributionResult. `IMarketProjector.Project(DistributionSnapshot, MarketKey)` returns MarketProbability with settlement partition. `IOddsNormalizer.Normalize(CompleteOddsSet, DeVigMethod)` returns market probabilities and diagnostics. `IValueEvaluator.Evaluate(...)` consumes exact contract-compatible outputs. No EF entities in these signatures. Errors include InvalidOdds, IncompleteMarket, StaleQuote, UnsupportedRules, IncoherentMass, ResourceLimit, ModelNotReady, MissingCoverage and UncertaintyUnavailable.
