# Desktop UX specification

WinForms with testable presenters. Forms gather intent/render immutable view models; no DbContext, model fitting, source parsing or settlement logic in UI handlers. Use asynchronous HTTP, cancellation and monotonically increasing request sequence; a slower old request cannot overwrite a newer fixture. Navigation preserves league/season/cutoff/profile context and clears invalid team selections when league changes.

| Workspace | Main workflow | Required evidence / failure state |
|---|---|---|
| Match Center | select fixture → request forecast → inspect headlines/explanation | cutoff, saved prediction ID, model/readiness, coverage; no unsaved provisional probability |
| Team Explorer | compare overall/venue/recent histories | unique fixtures, n/missing, weighted versus ordinary stats |
| League Tables | filter season/date and tie-break rules | distinguish official rules/deductions from statistical rankings |
| Referee Explorer | inspect card/foul history and shrunk model effects | assignment known-at, n and neutral fallback |
| Market Ladders | select family/period/line | coherent over/under ladder, push/half returns, unavailable reasons |
| Odds and Value Lab | enter/import odds → compare compatible groups | price age, margin convention, delta, costs, EV and uncertainty |
| Model Lab | inspect candidate runs, proper scores and calibration | no training score labelled OOS; promotion history |
| Prediction Journal | find/replay/export frozen forecast | immutable versions; corrections shown as later events |
| Data Manager | preview import → resolve aliases/issues → activate | row evidence, partial batch, affected market scope |
| Settings and Profiles | edit draft → compare → approve | exact version/hash, staged versus active settings |
| Help and Glossary | explain metric/model/market settlement | OBS/EXP/PROB/FREQ/VER/RULE definitions and worked examples |
| Operations | inspect jobs/schedules/alerts/audit/backups | retry reason, failed lease, last restore proof, drift |

Every workspace defines Loading (cancel/progress), Empty (next action), Partial (which fields absent), Stale (timestamp/reason), Failed (safe code/correlation/retry) and Offline (saved data only). Never use0% for an empty cohort. Native controls first; simple chart rendering includes a numeric table equivalent. Large tables paginate/virtualize, default page100.

Keyboard: logical tab order, visible focus, accessible names, Enter activates focused primary action, Escape cancels current dialog/job request safely; no global destructive shortcut. Test100/125/150/200% DPI, high contrast, resize and long pt-BR strings. Do not rely on colour alone for value/readiness. Display local time with timezone and expose UTC in provenance; decimal culture affects display/input parsing only.

Acceptance journey: import sample → resolve one alias → select fixture → save forecast → inspect value against manual prices → complete synthetic outcome → inspect paper ledger/report → back up and restore into separate instance. UI test records screenshots/keyboard evidence on Windows and verifies journal IDs through API, rather than matching pixels alone.
