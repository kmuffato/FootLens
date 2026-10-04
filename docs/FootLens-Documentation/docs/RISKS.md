# Risk register

| ID | Risk | Mitigation / owner role | Trigger and action |
|---|---|---|---|
| K01 | Historic availability absent | Data owner separates Strict/Assumed and freezes provenance | No evidence → no strict replay claim |
| K02 | Own numerics inaccurate | Model maintainer independent oracle/gradient/tail fixtures | Domain/tolerance failure blocks affected model |
| K03 | Insufficient market/half data | Data owner cohort coverage and unavailable states | Below gate → disabled/experimental cohort |
| K04 | AI scope or dependency drift | Architect packet/ADRs/boundary and lock checks | Unexpected change → repair or new task |
| K05 | Overfitting/model shopping | Model owner preregistration/nested chronological evaluation | Test-informed change → new exploratory run |
| K06 | Paper ROI overstates achievable returns | Analyst costs/limits/timestamps/sensitivity | Unknown execution → AssumedExecution label |
| K07 | Worker retries duplicate effects | Operations fencing/idempotency/outbox and crash tests | Inconsistent ledger → pause settlement |
| K08 | Bad migration/backup | Operator staged restore and separate migrator | Failed restoration blocks release |
| K09 | Licence/source definition changes | Data owner source admission/versioning | Changed rights/semantics → quarantine adapter |
| K10 | Personal scope grows into SaaS | Owner explicit non-goals and ADR review | Remote/multiuser request → separate scope decision |
| K11 | Prompt injection/secrets leak | Security owner scoped connectors and untrusted-data boundary | Suspicious input → isolate/rotate if exposed |
| K12 | Legacy inventory unavailable | Migration owner recover exact source and reconcile | Cannot prove620 coverage → task remains Blocked |
| K13 | Long custom-math delivery | Architect usable Poisson baseline first | Delay → narrow candidate scope; never weaken accuracy |

Risk reviews occur at milestones and incidents. Each live risk gains actual owner, likelihood/impact, due date and evidence as implementation starts; role assignments here avoid inventing named operators.
