# C# implementation standards

Nullable reference types on; warnings-as-errors for owned code; async I/O with CancellationToken; no async void except UI event boundary that catches/report errors. Pure functions for numerics/settlement; explicit immutable value objects for IDs, market keys and UTC time. Domain methods protect invariants. Use records/DTOs across modules, not tracked EF entities. Prefer short business-specific handlers over reflection-heavy frameworks.

Money/odds decimal, line-quarter integer, numerical probabilities double with domain/range checks. Invariant serialization/canonical hashing, stable ordering, no local time in persistence. Do not mix display rounding with computation. Result types distinguish unavailable/invalid/resource-limit/non-convergence; exceptions for unexpected faults are logged safely with correlation and surfaced without secrets.

Use injected clock and seeded sampler for deterministic tests; avoid global mutable Random/DateTime.Now/config. Dispose streams/contexts; bounded buffers, pagination and cancellation. No blocking .Result/Wait on UI or API request. Presenter starts operations and discards stale responses. Large fits run queued with checkpoints.

DB writes belong to owning store/use case; explicit transaction around aggregate/outbox/audit. Parameterised SQL for reviewed queue/bulk operations; no interpolation of identifiers from user text. Concurrency token conflicts handled, not swallowed. Migrations owned by one task at a time. No auto-lazy-loading or generic repository wrappers that obscure query cost.

Each PR describes behaviour trigger/before-after, invariant changes, tests, migration/compatibility and actual limits. No broad formatting churn in a mathematical fix. No generated source copied without provenance/licence review. Code comments explain nonobvious numerical assumptions/failure handling, not restate syntax.
