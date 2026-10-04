# API and application contracts

## Transport and access

ASP.NET Core JSON API at loopback http://127.0.0.1:5188 by default. Bearer token required for business endpoints; generate256-bit token at installation, keep outside Git in OS-protected per-user storage, and protect service-side hash/config with file ACLs. No browser CORS by default. Tokens are not a replacement for TLS on a network; remote/LAN mode requires TLS and a new security deployment review. Liveness exposes no data; readiness may require operator auth. Server never logs Authorization headers.

JSON enums are stable string names; IDs UUID; UTC dates ISO8601 Z; money/decimal odds use invariant decimal strings to preserve client precision. Probabilities are finite JSON numbers. Unknown fields in mutation DTOs reject with400 to catch agent/client drift. Version API under /api/v1; incompatible DTO or market semantic changes create v2 or new contract version. All responses include correlationId; accepted jobs include location and jobId.

## Endpoint catalogue

| Method / path | Input | Output / semantics |
|---|---|---|
| GET /health/live | none | 200 process alive; no DB dependency |
| GET /health/ready | operator | 200 ready or503 DB/schema/critical readiness failure |
| POST /api/v1/imports | multipart file + source/mapping/availability policy | 202 durable Import job; Idempotency-Key |
| GET /api/v1/imports/{id} | id | accepted/quarantined counts, issues and status |
| POST /api/v1/aliases/decisions | source text/context/target/evidence | 201 append decision; require expected mapping version |
| GET /api/v1/fixtures | league, season, from, to, cursor | bounded page max200; timestamp+ID cursor |
| GET /api/v1/statistics/teams/{id} | period, cutoff, metric | summary with n/missingness/lineage |
| POST /api/v1/forecasts | fixtureId, asOfUtc, profileVersionId, mode | 202 job; journal is retrievable after commit |
| GET /api/v1/forecasts/{id} | id | immutable snapshot, markets, diagnostics |
| GET /api/v1/forecasts/{id}/explanation | id | source/model/assumption provenance |
| POST /api/v1/odds/groups | exact contract group + quotes | 201 immutable group; reject duplicates with different payload |
| POST /api/v1/value-comparisons | predictionId, oddsGroupId, costPolicyId | 200 compatible comparison or422 semantic mismatch |
| POST /api/v1/backtests | frozen RunSpec | 202 durable replay job; seed/hash |
| GET /api/v1/backtests/{id}/report | id | 200 report manifest, or409 incomplete |
| POST /api/v1/experiments | protocol hash, allowed data/model grid | 202 experiment job; no promotion side effect |
| POST /api/v1/governance/approvals | exact artifact hash/evidence/decision | 201 audit event; operator only |
| POST /api/v1/governance/readiness | cohort/model/state/reason | 201 transition; expected current event ID required |
| GET /api/v1/audit | target, actor, date, correlation, cursor | bounded searchable history |
| GET /api/v1/jobs/{id} | id | state, progress, checkpoint, redacted error |
| POST /api/v1/jobs/{id}/cancel | expected version | 202 cancellation request |
| POST /api/v1/jobs/{id}/retry | expected version, reason | 202 new attempt, same logical idempotency identity |
| GET /api/v1/alerts | state/cursor | actionable diagnostics |

Token is one personal operator identity initially; audit still distinguishes service/job/agent actor metadata. Client-supplied actor names are not trusted security principals. Mutations require a bounded Idempotency-Key and payload hash. Same key+same hash returns the original resource; same key+different hash409. Version conflicts409; malformed400; auth401; forbidden403; missing404; unsupported semantic contract422; quota/rate429 with retry; service unavailable503. ProblemDetails carries stable code, safe detail and correlationId, never stack/connection string.

## DTO sketch

```csharp
public sealed record ForecastRequest(Guid FixtureId, DateTimeOffset AsOfUtc,
    Guid ProfileVersionId, string Mode);
public sealed record MarketKey(string Family, string Period, string Selection,
    int? LineQuarter, string RulesVersion);
public sealed record SettlementMass(double Win, double HalfWin, double Push,
    double HalfLoss, double Loss);
public sealed record ProbabilityBand(double Lower, double Upper,
    string Method, int SuccessfulDraws);
public sealed record MarketResult(MarketKey Key, SettlementMass? Mass,
    ProbabilityBand? Band, string Readiness, string? ReasonCode);
public sealed record JournalResponse(Guid PredictionId, Guid DistributionId,
    string SnapshotHash, DateTimeOffset AsOfUtc, string AvailabilityMode,
    IReadOnlyList<MarketResult> Markets);
```

Unavailable market uses Mass=null; its metadata still explains missing inputs. Band concerns the declared event (normally full-win for a binary market); Asian expected payoff uncertainty is a distinct field, not a misleading win interval. JSON schema version and key units must match market registry.

## Request transaction example

CreateForecast endpoint validates IDs/auth/body/key, calls enqueue handler, commits job and request identity, returns202. Worker checks readiness; freezes snapshot; calculates distribution; begins short commit transaction; locks job lease row and verifies generation/token; inserts distribution, prediction, markets and audit; marks job succeeded; commits. Crash before commit leaves no partial prediction. Lost HTTP response repeats same key and receives same job/prediction. Changed model/config cannot be substituted within an existing key.

OpenAPI generation is FL-001/FL-009 output. Contract integration tests assert auth, max size, errors, pagination, cancellation and idempotency. This catalogue is the initial design; it is not a claim that endpoints already exist.
