# Configuration and operational defaults

Separate host secrets/settings from immutable analytical profiles. Host settings include DB connection, API binding/token source, artifact/log/backup roots and worker budgets. Analytical profile includes model priors/grids, cutoff policy, numerical tolerance, calibration, odds freshness/cost policy and paper strategy. Editing an approved profile creates a Draft revision; approval activates its exact hash without rewriting predictions. Environment variables may override host settings only, never silently replace a saved analytical profile.

| Setting | Default | Validation |
|---|---|---|
| Host endpoint |127.0.0.1:5188 |nonloopback requires explicit secure deployment config |
| CPU workers |2 |1–8; one concurrent fit per league/model |
| Job lease / heartbeat |60s /20s |heartbeat<lease/2 |
| Attempts / retry delays |3 /30,120,600s |attempt budget checked before scheduling next retry |
| Source automation |disabled |admitted source/permissions required |
| Upload size / JSON depth |100MB /64 |hard bound before parsing |
| Goal tail / support |1e-9 /256 per axis |failure returns ResourceLimit |
| Secondary support / convolution ops |2048 /1m |no silent truncation |
| Quote age / group span |15m /60s |rules/book/contract exact match |
| Replay windows |730d train,90d calibration/validation,30d outer |minimum365d train; weekly eligible refit |
| Parameter / metric bootstrap |200 /1000 |≥180 successful parameter draws |
| Paper bankroll / fixed stake |10000 /1 unit |one currency, positive balance, no real execution |
| Exposure caps |1% position,3% fixture,10% open |pre-batch equity; proportional reduction |
| Backup RPO/RTO |24h /4h |measure by restore drill |

JSON schema rejects unknown fields, invalid domains and incompatible combinations. Profile carries schemaVersion; migration between schemas produces new payload/hash with transformation report. Seed and availability policies mandatory for replay. No production credentials in checked-in examples; only variable names/secret provider references.
