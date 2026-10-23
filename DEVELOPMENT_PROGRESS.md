# ShuleLite development progress

This report is based on source and schema inspection. A clean PHP syntax pass is not a runtime test.

## Phase 0 — Audit and stabilization

### Existing feature coverage

| Area | Status | Source findings |
| --- | --- | --- |
| Sign-in, password changes, account status | Partial | Password hashing, CSRF, forced password changes, and disabled-account checks exist. Login throttling, session cookie policy, and centralized authorization are absent. |
| School and team administration | Partial | School editing/review, membership scope, account creation/reset/suspension, subscriptions, and audit history exist. Authorization policy is repeated in page controllers and role coverage is uneven. |
| Academic setup and learning materials | Partial | Schemes, approved-topic lesson plans, confirmed teaching records, stream-aware coverage, teacher reports with period activity and coverage snapshots, department-scoped review/activity, AI-assisted editable drafts, and print/Word-compatible exports are implemented in code. Phase 1 feature work is complete for the current scope; migration/runtime/browser/role-isolation verification remains a release gate. Department-head narrative review is intentionally not exposed because existing teacher reports are not subject-scoped. |
| Exams and results | Partial | Exam approval/publication, scoped score entry, question bank, paper workflow, read-only reports, and printable report cards are present in code. Controlled finalized-result corrections now use independent review and audit history. Configurable grading, runtime verification, and parts of examination automation remain incomplete. |
| Pupils | Partial | Registration, directory search, promotion, class history, guardian links, school-managed pupil accounts, audited transfer/graduation/reactivation, leadership-only demographic edits, and atomic CSV bulk enrollment are implemented. Runtime verification remains missing. |
| Attendance | Partial | Daily class register and audit trail exist. A school-scoped date-range aggregate report has been added and teacher queries are restricted to assigned classes. Absent/late attendance alerts now queue for opted-in linked guardians and are revalidated before send; other attendance notices and live database/browser verification remain incomplete. |
| School fees | Partial | Append-only charges/payments, reasoned discounts and discount reversals, balances, audit records, printable receipts/statements/invoices, fee structures, one-time bulk assessments, and CSV statement reconciliation with exact/manual receipt matching are implemented. Database-backed browser verification remains pending. |
| HR | Partial | Staff contracts, explicit renewal chains, expiry labels, school-scoped leave requests, separate employee profiles, and private staff documents are implemented in code. Staff check-in/out, daily HR/leadership attendance reporting, a school-scoped workload overview, and actionable in-app contract expiry alerts are implemented in code. Contract expiry alerts can be queued through the SMS worker; external delivery and live verification remain pending. |
| Stores | Partial | Stock items and auditable receipts/issues/adjustments, scoped requests/approvals, reorder alerts, suppliers, categories, and stocktake sessions are implemented. Receipt unit costs now support a disclosed latest-receipt-cost estimate in item views and the Stores dashboard; legacy items without a recorded receipt cost remain visibly unvalued. Database-backed browser verification remains pending. |
| Dashboards and communication | Partial | Basic system overview and school-edit notifications exist; teacher, Bursar, HR, Head of Academics, school leadership (Director, School Manager, Headteacher), and Storekeeper overviews load scoped data asynchronously. Teacher dashboard links into weekly timetables. Parent/teacher messaging and an SMS outbox for payment, attendance, exam publication, parent/all-school announcements, and manually requested fee reminders are implemented in code; contract-expiry events, per-school SMS templates, and scoped delivery history are implemented; provider configuration and runtime verification remain pending. |
| Parent/guardian portal | Implemented; verification pending | Parent accounts can link to multiple pupils and see linked-child fee summaries, recent attendance, published results, class learning materials, homework status summaries, holiday packages, and audience-filtered announcements. Parent/teacher messages now use assigned-class and linked-guardian scope, and payment notifications use guardian preference; SMS event coverage and live access/delivery verification remain incomplete. |
| Pupil portal | Implemented; verification pending | School-managed learner accounts can view their own published results, attendance summary, published class learning materials, holiday packages, audience-filtered announcements, assigned homework with submission/feedback, and published class timetables. The learner dashboard includes published subject assessment summaries and a recent homework completion snapshot; broader trend/portfolio tracking and live verification remain incomplete. |
| Holiday packages | Implemented; verification pending | Class-scoped package authoring, review/publication, reuse of published notes/questions, pupil completion/response, teacher feedback, print output, and parent visibility are implemented. Commercial access rules and runtime verification remain. |
| Asynchronous interactions | Partial | Audit search/pagination, SMS template settings and delivery history, and academic catalog actions use Fetch. Shared Fetch request utility and JSON contracts now cover academic catalog, planning, question bank, exam building, result entry, fee ledger entry/reversal, fee structures, and announcement authoring; academic report filters also refresh asynchronously. Most remaining legacy forms still submit full-page requests. |
| SomaTokeo boundary | Contract defined; exchange disabled | A versioned, minimized published-results JSON contract and implementation safeguards are documented under `integrations/somatokeo/`. No endpoint, transport, credential, or duplicate academic engine is enabled; school approval and stable opaque identifiers are required first. |
| SomaBus | Excluded | No SomaBus implementation is in scope. |

### Stabilization checks

- PHP CLI syntax check before academic productivity work: **passed**, 31 PHP files.
- PHP CLI syntax check after the current planning changes: **passed**, 29 PHP pages/endpoints under `public_html`.
- Node syntax checks for the shared request helper and planning client: **passed**.
- PHP CLI syntax check after the question-bank increment: **passed**, 31 PHP pages/endpoints under `public_html`.
- Node syntax checks for the question-bank client, planning client, and shared request helper: **passed**.
- PHP CLI syntax check after the exam-builder increment: **passed**, 33 PHP pages/endpoints under `public_html`.
- Node syntax checks for all five JavaScript assets: **passed**.
- PHP CLI syntax check after the asynchronous result-entry increment: **passed**, 33 PHP pages/endpoints under `public_html`.
- Node syntax checks for all six JavaScript assets: **passed**.
- Earlier database connection probe was unavailable; see latest recheck below.
- **Latest recheck:** PDO connects to the configured school database with 32 tables, but its schema is behind current migrations. The school database remains untouched. To verify the new stream migration safely, a uniquely named disposable database was created, loaded with the 73-table canonical schema, changed to pre-migration lesson schema, migrated successfully, and dropped afterward. Broader application runtime/authorization checks remain pending.
- Repository metadata: no `.git` directory is present in the supplied workspace, so there is no local commit history/diff baseline.
- `config.php` hardening: intentionally deferred per the user's earlier instruction until live testing is ready.

## Implementation phases

Phase status is based on checked source plus runtime gates. No implementation phase is closed until its connected workflows, authorization, migrations, and browser behavior pass against a suitable test database.

1. **Phase 0 — Audit and stabilization: source audit complete; runtime stabilization pending.** The connected MySQL database responds, but its 32-table schema is behind current migrations. No database writes have been made because it is not confirmed disposable and there is no verified backup.
2. **Phase 1 — Academic productivity: implementation complete; verification pending.** Schemes, lesson planning/review, confirmed teaching, stream-aware coverage, teacher reports with lesson/attendance/assessment/coverage snapshots, department-scoped review and activity reporting, AI-assisted editable drafts, lesson draft editing, and print/Word-compatible exports are implemented in source. Remaining work is validation against the supported MySQL schema, configured-provider AI checks, authenticated browser journeys, and role/school-isolation negatives. Department-head access to teacher narrative reports remains withheld until reports can be scoped by subject without exposing unrelated teacher content.
3. **Phase 2 — Examinations: implementation complete; release verification pending.** The source connects the question bank, AI-assisted question import and exam drafting, manual exam builder, review/scheduling, result entry and publication, controlled corrections, configurable grading, report cards, and academic analyses. Result publication checks readiness, blocks invalid scores/empty result sets, and requires an audited reason if active pupils are missing results. Candidate papers, marking schemes, and report cards have print and Word-compatible exports. Remaining gates are database-backed workflow/permission checks, authenticated browser journeys, configured-provider tests, and visual verification of exported documents. No grading policy is invented; configured school grading bands are used.
4. **Phase 3 — School operations: implementation complete; release verification pending.** Fee ledger/structures/reversals, authorized fee discounts, payment-statement reconciliation, Bursar scope, HR profiles/contracts/leave/attendance, inventory requests/stocktakes/suppliers/categories, latest-receipt-cost estimates, scoped dashboards, and asynchronous finance reconciliation are in source. Remaining gates: migration execution on the supported MySQL version, authenticated finance/HR/store journeys, permission and school-isolation negatives, and ledger/movement reconciliation checks.
5. **Phase 4 — Parent/pupil experience: implementation complete; release verification pending.** Linked guardians and school-managed learner accounts connect to published reports, attendance, fee summaries, learning materials, homework, announcements, timetables, parent/teacher messaging and holiday packages with progress and feedback. Report-period selection and package content scope were corrected in this increment. Remaining release gates: parent/pupil runtime and cross-school authorization checks, mobile/print review, and a school decision on optional commercial package entitlement; paid access is not enabled or assumed.
6. **Phase 5 — Integrations/refinement: implementation complete; release verification pending.** Reusable event templates, school SMS outbox, SomaSMS transport, bounded retries, delivery polling, guardian/recipient revalidation, event cancellation, contract expiry reminders, scoped async delivery history, per-school template settings, and a versioned SomaTokeo published-results contract are in source. The worker now respects Phase 3 discounts in arrears checks, cancels exam alerts for inactive pupils, and reports delivery only after explicit provider delivery confirmation. Remaining gates: disposable-database concurrency/provider behavior, applying the new migration to the selected deployment/test schema, secure provider configuration during an approved live-test window, and cross-role accessibility/performance/regression review. SomaBus is excluded.

**Completion count for requested Phases 1–5: 0 fully closed; 5 still have source/runtime work.** This reflects required runtime gates and listed missing functionality, not absence of the implemented foundations.

## Current increment — Phase 1 planning foundation

- **New:** `schemes_of_work`, `scheme_topics`, `lesson_plans`, `teaching_records`, and `teacher_reports` schema/migration definitions.
- **New:** asynchronous planning page and JSON API for scheme drafts, submissions, academic review, revisions, lesson plans, teaching confirmation, and curriculum coverage.
- **Connected:** approved scheme topics feed lesson plans; confirmed teaching records feed coverage. Teachers see approved schemes only when assigned to the corresponding class and subject.
- **Security:** endpoint enforces authenticated school membership, CSRF on writes, role checks, teacher assignment checks, and audit events. These controls have not received database-backed authorization tests yet.
- **Corrected during review:** coverage periods are now calculated in independent aggregates so topic/lesson joins do not inflate planned or delivered periods.
- **Navigation and checklist:** teaching plans are linked from the role navigation; the teacher and Head of Academics QA checks include the new flow.
- **Teacher reports:** teachers can create/edit draft or returned reports for daily, weekly, monthly, or termly periods, view scheduled/delivered lesson and period counts for the selected range, and submit reports. Academic reviewers can approve or return with feedback. A unique school/teacher/type/date-range key prevents duplicate reports for the same period. Narrative fields remain teacher-authored.
- **Database changes:** migration `20261021_academic_productivity.sql`; the corresponding definitions were added to `database/schema.sql`. Migration application is pending because local MySQL is refusing connections.
- **Not verified:** SQL execution, live permissions, cross-school negative tests, duplicate teaching/report submission behavior, UI interaction, and document generation. A fresh PDO probe returns MySQL error 2002 (connection refused).
- **Phase 1 completion note:** AI scheme/lesson draft assistance, Word-compatible and print exports, stream-aware coverage, and period-bound teacher-report curriculum snapshots were added in subsequent increments. Coverage counts now use period-scoped lesson and teaching records; teacher confirmations require an active class/subject assignment. Static checks pass; authenticated browser, provider, and database-runtime verification is still outstanding.

## Current increment — Phase 2 question bank

- **Existing foundation:** `ai_questions.php` generates question sets as Markdown from accessible learning notes, while `school_exams` and `pupil_results` provide a minimal existing exam/results path.
- **New:** migration `20261101_question_bank.sql` and matching `question_bank` table in `database/schema.sql`; the table links school/class/subject, prompt/type/difficulty/marks, options and marking content, author, reviewer, status, and audit timestamps.
- **New:** asynchronous question-bank UI and JSON endpoint for manual drafting, teacher submission, academic review, publication, search, and archival. Multiple-choice answers must match one of the stored options.
- **Security:** endpoint checks school membership on every request, teacher assignment for class/subject authoring and visibility, CSRF on state changes, role-gated review/publication, and audit events. Database-backed checks remain unavailable.
- **AI connection:** the generator now requests a structured question set and offers a school/class/subject-scoped import into the bank. Imported questions are AI-sourced drafts that must go through the existing review and publication lifecycle.
- **Not verified:** migration execution, browser interactions, authorization negatives, question review lifecycle, and cross-school isolation. MySQL connection remains refused.

## Current increment — Phase 2 exam paper and result states

- **Schema:** migration `20261102_exam_builder.sql` extends `school_exams` with subject, term, schedule, duration, instructions, total marks, review status, and a lifecycle. Existing rows receive `results_open` as the migration default to preserve legacy result entry. New builder records explicitly start as `draft`. `exam_paper_questions` links ordered, sectioned paper items to bank questions. Canonical `database/schema.sql` now includes the corresponding fields and table.
- **Connected workflow:** the asynchronous builder selects only published questions for the chosen class and subject, saves a draft, and supports submission, academic review, scheduling, opening result entry after the scheduled date, and result publication. The result-entry page remains the existing workflow and now uses the paper's total marks for the maximum score.
- **Printed output:** candidate paper and separate marking scheme render in a print-ready browser window (including Save as PDF via browser print). Word-compatible candidate paper and marking scheme exports were added in a later increment.
- **Result integrity:** ordinary score writes require `results_open`; the exam row is locked and rechecked inside the score transaction to avoid a publish/write race. Results cannot be viewed until result entry opens, and publication changes state to read-only.
- **Asynchronous result entry:** the legacy score grid now saves through JSON/Fetch without a page reload. Newly entered cells are converted in place to saved score fields. Unchanged scores no longer create redundant audit updates. The standard form POST path remains available as a fallback.
- **Security:** exam writes are school-scoped and CSRF-protected; non-review roles must match an active class/subject assignment. Question selection revalidates school, class, subject, and published state inside the exam save transaction. State changes are audited.
- **Not verified:** MySQL still refuses connections (PDO error 2002); migrations and database-backed workflows, asynchronous result-entry regression, authorization negatives, browser print output, and result locks have not been exercised at runtime.
- **At this increment, remaining Phase 2:** teacher review/scope refinement, grading-rule refinement, Word report-card export, and completeness checks before publication. These features have since been implemented in source; database-backed and browser verification remains outstanding. Grade distribution and same-term assessment trend tables are implemented in code. AI question import and published-result correction are not yet runtime-tested.

## Current increment — Phase 2 examination completion

- **Exam drafting:** added an AI-assisted paper draft action that selects only published, same-school/class/subject question-bank items. It validates the response against bank IDs, enforces an existing per-user request limit, sends no pupil data, and returns an editable selection without saving or publishing an exam. Manual selection remains available.
- **Paper workflow:** added one-time question randomization at save; the resulting sequence is stored and reused for candidate and marking output. Added draft duplication with unique names, preserved question sections/order/marks, and cleared exam date and approval state.
- **Documents:** added Word-compatible `.doc` downloads for candidate papers and separate marking schemes alongside print/Save as PDF output. Reviewer answer keys remain omitted from non-reviewer exam detail responses.
- **Access correction:** non-reviewers can open their own drafts/returned work and assigned exams only after they are scheduled or results are open/published. Draft duplication applies the same scope. The exam list now displays duplication only for records the user can reuse.
- **Checklist:** added Phase 2 end-to-end cases in `public_html/dev.html` for manual and AI drafts, validation/throttling, stable randomization, duplication, answer-key isolation, exports, lifecycle, publication, corrections, grading, and authorization.
- **Database changes:** none in this increment. `config.php` was not modified.
- **Checks run:** PHP syntax check for the exam API, JavaScript syntax check for the exam UI, and inline-script syntax check for `dev.html` pass. Imported `database/schema.sql` into a temporary database after replacing its hard-coded database name in memory; all 74 tables and the Phase 2 question, exam, grading, correction, and report-card structures were verified, then the temporary database was dropped. The configured school database was not written to, and `config.php` was not changed. Authenticated browser journeys, configured AI-provider behavior, document rendering, and role/school-isolation cases remain release-verification gates. Phase 2 is implementation-complete in source, not release-verified.

At each phase end, update the status and record checks actually executed. Do not mark a feature complete from a rendered interface alone.

## Current increment — Finance access and fee ledger controls

- **New role:** added the school-scoped `bursar` role to the canonical schema and migration. Directors and school managers can create Bursar accounts. Bursars are routed to fee accounts and do not see school management, team management, operations, or learning-material navigation.
- **Permission correction:** removed HR from fee-account page access and navigation. Fee access checks still require explicit school membership; all account ledger queries use the selected member school.
- **Ledger integrity:** migration `20261103_bursar_and_fee_reversals.sql` adds charge/payment reversal types, a nullable unique reference to the original entry, a required-at-API reason, and a self-referencing foreign key. Reversals append a compensating ledger entry and audit event; a unique constraint and row lock prevent double reversal. Payments/reversals recalculate net balances.
- **Async workflow:** fee charge/payment submissions now use the shared Fetch helper, return the saved ledger row and recalculated totals, and update the account without a page reload. Reversal dialog posts asynchronously, blocks duplicate clicks, and updates the ledger/totals on success.
- **Test checklist:** added Finance / Bursar access, charge/payment, reversal, audit, double-reversal, and cross-school authorization scenarios to `public_html/dev.html`.
- **Not verified:** the migration and finance role/ledger flows cannot be exercised until MySQL is available. Browser-level checks and cross-school authorization tests remain pending. This increment adds no fee-structure, invoice, discount, reconciliation, or arrears-reporting workflow.
- PHP syntax check after the finance/Bursar increment: **passed**, 34 PHP pages/endpoints under `public_html`.
- Node syntax check after the finance/Bursar increment: **passed**, all 7 JavaScript assets.
- Database-backed migration, account mutation, and permission tests: **not run** because the local MySQL service previously refused connections (PDO error 2002).

## Current increment — Inventory request and approval workflow

- **New:** migration `20261104_inventory_requests.sql` and canonical schema define school-scoped stock requests with pending, approved, rejected, issued, and cancelled states. Inventory movements can reference a request; a unique key permits at most one issue movement per request.
- **Connected:** storekeepers and authorized school managers can submit requests. School managers can approve/reject pending requests. An approved request can be issued only once; the issue locks the request and stock item, validates available balance, decrements inventory, records a linked movement, and writes an audit event in one transaction.
- **Scope:** requests are read and mutated using the selected school ID after membership validation. Manager-only approval is checked server-side. Existing manual receipts/issues/adjustments remain available.
- **Test checklist:** added request review, approval, issue-once, stock-balance, audit, and cross-school checks to `public_html/dev.html`.
- **Not verified:** migration and transactional behavior require a running MySQL service. Browser workflow, unauthorized requests, double-issue concurrency, and mobile layout remain untested. This increment’s forms still use the existing full-page POST workflow; the broader asynchronous-page requirement remains in progress.
- PHP syntax check after the inventory request increment: **passed**, 34 PHP pages/endpoints under `public_html`.
- Node syntax checks after this increment: **passed**, all 7 JavaScript assets and the inline role-checklist script.

## Current increment — Asynchronous school operations

- **New:** `public_html/assets/operations.js` intercepts POST forms on the operations workspace and submits them through the shared `ShuleApi` helper. Attendance, contract, stock, and request actions now return JSON, then refresh the rendered workspace content asynchronously without a document navigation. Duplicate submits are blocked while the request is pending; server and network errors are shown inline.
- **Server behavior:** `operations.php` continues to perform its existing validation, role checks, school membership checks, transactions, and audit writes. JSON requests receive explicit 400 session/CSRF errors, 422 domain errors, and success messages; ordinary POST fallback remains supported.
- **Test checklist:** added async operation, error, duplicate-click, and failed-request checks.
- **Checks:** PHP syntax passed for 34 public pages/endpoints; Node syntax passed for all 8 JS assets; the inline checklist script compiles.
- **Runtime:** MySQL service is not present in the local service inventory, and PDO connection still returns error 2002. Database-backed and browser runtime checks remain outstanding.
- PHP syntax check after adding the asynchronous operations path: **passed**, 34 PHP pages/endpoints under `public_html`.
- Node syntax checks after adding the operations client: **passed**, all 8 JavaScript assets and the inline role-checklist script.

## Current increment — Parent account links and parent portal

- **Schema:** migration `20261105_parent_guardian_links.sql` adds the `parent` role and a `pupil_guardians` relation with school/pupil composite scoping, relationship, primary guardian, notification preference, and linker audit identity. Canonical schema includes the matching definitions.
- **Account workflow:** authorized school administrators can create a parent account or link an existing active parent account to a pupil. New accounts receive a random temporary credential shown once to the linking staff member and must change it at first login. One parent may be linked to multiple pupils, and each pupil may have multiple guardian links. Administrators can remove a specific link; removing a primary link promotes another guardian when available. Account records are not granted general school membership.
- **Portal:** parent sign-in routes to a parent-only portal. It queries children only through the signed-in guardian’s link rows, and shows linked pupil fee balances/recent ledger activity, a 30-day attendance summary, and only results whose matching school exam is `results_published`. Unpublished results and staff records are excluded. Direct access to the general result route remains role-denied.
- **Privacy:** parent accounts are omitted from the staff directory and contract staff selection. The parent-specific sidebar contains only the child portal plus personal account/sign-out links.
- **Test checklist:** added parent multi-child/multi-guardian, revocation, publication-state, cross-school, and role-denial cases to `public_html/dev.html`.
- **Not verified:** migration execution, account/link transactions, parent login, school isolation, and result publication filtering need live MySQL/browser tests. No guardian identity verification or notification delivery has been fabricated; school staff must confirm the guardian before linking. Parent-facing materials, announcements, notifications, and messaging remain incomplete.
- PHP syntax check after adding parent accounts and the portal: **passed**, 35 PHP pages/endpoints under `public_html`.
- Node syntax checks after this increment: **passed**, all 8 JavaScript assets and the inline role-checklist script.

## Current increment — School-managed pupil accounts and learner portal

- **Schema:** migration `20261106_pupil_portal.sql` adds the `pupil` role and `pupil_accounts` mapping. Each pupil and account can have at most one mapping; the school/pupil composite foreign key prevents linking a pupil under a different school. Account access can be revoked and restored with history fields.
- **Account workflow:** school administrators can create or restore a pupil account with a temporary password and required first-login password change. Accounts receive no school membership. Administrators can revoke portal access; the same learner account can only be restored to its original pupil.
- **Portal:** pupil login routes to `pupil_portal.php`; the page resolves only the active pupil mapping for the signed-in user. It shows that pupil’s published results, a recent attendance summary, and published central materials or published teacher notes scoped to the pupil’s class and school. Fees, other pupils, staff data, and unpublished academic content are not included.
- **Privacy and navigation:** the pupil sidebar contains only the learner portal, personal account, and sign-out controls. The role has no school membership and does not satisfy staff/admin page role checks.
- **Test checklist:** added account setup/revocation, own-record, publication filtering, class/school material scoping, and direct-access denial checks.
- **Not verified:** database migration, account lifecycle, guardian-assisted login, result release filtering, materials scope, and cross-pupil/cross-school isolation await live runtime tests. Homework assignment, timetable, announcements, and broader progress tracking remain incomplete.
- PHP syntax check after the learner portal increment: **passed**, 36 PHP pages/endpoints under `public_html`.
- Node syntax checks after the learner portal increment: **passed**, all 8 JavaScript assets and the inline role-checklist script.

## Current increment — Holiday Learning Packages

- **Schema:** migration `20261107_holiday_learning_packages.sql` and canonical schema add class/subject packages, ordered material/exercise/activity items, and per-pupil progress/response/teacher feedback. Composite school foreign keys preserve package, pupil, and progress school scope.
- **Authoring and review:** `holiday_packages.php` and `api/holiday_packages.php` support drafts, ordered content, note/question reuse, submit, independent review, publish, archive, and completion reporting. Authors can use only published learning notes/questions matching package class/subject; non-review roles must have an active matching teacher assignment. Reviewers cannot approve their own submission.
- **Class assignment and learner work:** publishing seeds progress rows for current active pupils in the package class. Learners with active school-managed accounts can open currently available packages, print/save as PDF, and asynchronously save a response and progress state. The portal filters packages by school, current class, published state, and availability dates. Question prompts/options are displayed without model answers.
- **Parent connection:** each linked guardian sees currently available packages and progress for their linked child; the parent view is read-only. Teachers and academic reviewers can see package progress, and assigned teachers can leave feedback that appears to the learner and linked parent.
- **Test checklist:** added package drafting/review/publication, source-content scope, completion, feedback, parent visibility, answer-key exclusion, and asynchronous save checks.
- **Not verified:** migration application, API/browser flow, row-locking, cross-school/cross-child authorization, availability boundaries, and feedback visibility need live MySQL/runtime checks. Commercial/package payment rules remain deliberately unconfigured pending product rules; all published packages use the school’s class assignment and availability window.

- **Final review for this increment:** moved the management-role gate ahead of the catalog response so unrelated school roles cannot fetch package authoring catalogs. The API continues to enforce school membership, role, assignment, package state, and guardian/pupil link scope server-side.
- **Static verification:** PHP syntax passed for all 39 public PHP files; Node syntax passed for all 10 JavaScript assets. The updated role-based checklist includes holiday-package authoring, review, answer-key privacy, learner progress, teacher feedback, and parent visibility.
- **Still pending:** database migration/application and live workflow tests. The local MySQL service remains unavailable (PDO error 2002 in prior probes). `config.php` was left unchanged as instructed.

## Current increment — Staff leave requests

- **Schema:** migration `20261108_staff_leave_requests.sql` and canonical schema add school-scoped leave requests with type, date range, reason, pending/approved/rejected/cancelled states, review note, reviewer, and timestamps. Indexes support school/status and staff/date lookup.
- **Workflow:** staff submit and view their own requests; they can cancel pending requests. HR and authorized school managers can view school requests, approve or reject another staff member’s pending request, and cannot approve their own request. The server checks school membership, validates dates, rejects overlapping pending/approved requests, and prevents approval that overlaps an existing approved leave.
- **Audit and async:** submission, cancellation, approval, and rejection create audit events. The existing asynchronous operations form handler saves and refreshes the leave view without full-page navigation; duplicate clicks are blocked by the shared handler. Bursar and driver accounts can reach the leave-only operations view; this does not expose finance or transport features.
- **Test checklist:** HR checklist now covers submission, invalid/overlapping dates, own-request scope, cancellation, review permissions, self-review denial, audit records, and school isolation.
- **Not verified:** migration application and DB-backed behavior remain untested because MySQL refuses the connection (PDO 2002). Race behavior under simultaneous overlapping submissions, notification delivery, leave balances/entitlements, and statutory policy are not implemented; no leave entitlement rules have been assumed.


## Current increment — Class fee structures and bulk assessment

- **Schema:** migration `20261109_fee_structures.sql` adds school/class/year/term fee structures, ordered amount lines, and per-pupil assessment records linked to the existing fee ledger. Composite foreign keys enforce class, pupil, structure, item, ledger, and school scope. Existing manual charges, payments, and reversal history remain intact.
- **Workflow:** authorized finance roles can create drafts, add/remove fee lines, publish a schedule, apply it to active pupils in its class, and archive a schedule. Applied lines create charge entries in the existing ledger; unique assessment keys prevent duplicate charges on repeat application. The whole class application and audit record share one transaction. Published schedules are locked from line edits.
- **UX and permissions:** added `fee_structures.php`, `api/fee_structures.php`, and an asynchronous form client. Only school managers and Bursars can access the module; HR and teaching roles have no fee-structure access. School membership and class scope are validated server-side. Applying charges requires an explicit browser confirmation.
- **Test checklist:** finance QA now covers draft authoring, invalid amounts, publish lock, class-scoped application, repeated application, ledger/reversal continuity, school isolation, and role denial.
- **Not verified:** migration compatibility, DB constraints, bulk transaction behavior, ledger results, and browser interactions need live MySQL testing. This does not yet provide invoices, discounts/scholarships, reconciliation, or arrears reporting.

## Current increment — School announcements

- **Schema:** migration `20261110_school_announcements.sql` and canonical schema add school-scoped announcements with audience (all, parents, pupils, staff), draft/published/archived lifecycle, optional expiry, and creator/publisher audit identities.
- **Authoring:** authorized school leaders can create drafts, publish them to a selected audience, and archive them. Writes use CSRF-protected asynchronous requests, membership validation, and audit events.
- **Audience views:** added a notice board for parent, pupil, and staff accounts. It resolves parent access through active linked pupils, learner access through the active pupil account, and staff access through school membership. Readers see only published, unexpired announcements matching their audience and school scope.
- **Test checklist:** added authoring, audit, expiry, publication-state, audience-filter, active guardian/pupil link, and school-isolation checks.
- **Not verified:** migration application, API authorization/audit behavior, parent-child isolation, expiry boundaries, and browser interactions require live MySQL testing. SMS/email delivery and scheduled publication are not implemented.
- **Static checks:** PHP syntax passed for all 44 public PHP files; Node syntax passed for all 12 JavaScript assets; the role-based test checklist script compiled; and the announcement table definition matches between the migration and canonical schema. Database-backed and browser tests remain unrun because the current PDO probe returns MySQL error 2002 (connection refused).

## Current increment — Published academic reports

- **New:** `academic_reports.php` provides read-only reports for published exams and their published score assessments. It shows pupil score and normalized percentage, assessed count, mean/high/low, stream averages, and comparison with the previous published exam in the same class and subject when the matching assessment exists.
- **Security:** school membership scopes the report; teachers see only exams matching active teacher assignments or result delegations. Other authorized academic and school-management roles remain limited to their linked schools. Unpublished exams are excluded.
- **Reporting policy:** no grade bands or cutoffs are invented. Results are normalized by each recorded maximum score. Report filters refresh asynchronously and the report prints through browser print; printable report cards with teacher/headteacher comments were added in a later increment; configurable grading rules remain future work.
- **Test checklist:** added publication-state, teacher scope, score normalization, stream aggregation, and historical comparison checks.
- **Not verified:** runtime aggregation, query behavior, teacher authorization, print layout, and cross-school isolation require MySQL and browser testing; MySQL remains unavailable locally (PDO error 2002).

## Current increment — Printable pupil report cards

- **New:** `report_card.php` assembles a printable report from published examination results for one pupil and period, with score normalization and optional teacher/headteacher comments. Configurable grading policy remains unimplemented; the page explicitly avoids inventing grade bands.
- **Workflow and security:** migration `20261111_pupil_report_cards.sql` adds school-scoped draft/published report cards with comment authorship and publication metadata. The API checks membership, published results, teacher assignments/result delegation, manager publishing rights, CSRF, and audit events. Parent access resolves active linked pupils; pupil access resolves only the account’s own active record. Parent/pupil views exclude draft cards.
- **Async:** comment and publish actions use fetch, prevent repeat submits, ask for publish confirmation, and refresh the selected report after success. Legacy records with a blank term remain selectable.
- **Static QA:** PHP syntax passed for all public pages/endpoints; the inline test-checklist script compiles. `config/config.php` SHA-256 remains `97817B66039004DF01E644B0CF0BCEB568FD5F0E78225BD1F8F48E01802EEDB1`.
- **Not verified:** MySQL connection remains unavailable, so migration application, SQL behavior, parent/pupil report visibility, print rendering, and browser/API flows are untested. Parent and pupil portals now link directly to their published report cards; report-card checklist coverage is in place. These changes have static checks only. Department-head workload/reporting, grading configuration, dashboards, HR completeness, stores, SomaSMS, and several other directive items remain incomplete.

- **Portal connection follow-up:** parent and pupil dashboards now list published report-card periods and link to the period-specific card. Staff and guardian period filters load asynchronously and support browser back/forward navigation. Static checks passed after this follow-up; DB/browser verification remains pending.


## Current increment — Inventory reorder thresholds and low-stock alerts

- **Schema:** migration `20261112_inventory_reorder_thresholds.sql` adds a nullable, non-negative decimal reorder threshold to existing inventory items; matching canonical schema updated. Existing balances and movement history are untouched.
- **Workflow:** store roles can set or clear thresholds when adding an item and update them directly from the stock list. The school operations page flags items whose current ledger-maintained balance is at or below the configured threshold. Unconfigured items remain unflagged.
- **Security and history:** threshold writes use the existing school-scoped stock action, role gate, CSRF and asynchronous form handler; item updates retain before/after values in the existing audit log. Thresholds do not alter stock balances or create movement records.
- **Test checklist:** added bounds, low/equal/above threshold, balance movement, role and school-scope checks.
- **Not verified:** static PHP/JS checks only. Migration application and behavior against MySQL and live ledger data still require runtime tests; local MySQL remains unavailable.


## Current increment — School fee arrears report

- **New:** the school fee account page now lists pupils with a positive outstanding balance, sorted by balance, with school-scoped links to open each account and a print action. Inactive and graduated pupil records remain reportable when they have outstanding balances.
- **Balance integrity:** the aggregate uses the same signed ledger formula as pupil accounts, including charge and payment reversals. It creates no financial entries and does not alter balances.
- **Access:** the report resides inside the existing accounting page, which enforces authorized school membership and the finance role allowlist.
- **Test checklist:** added checks for reversal math, totals, former pupils, pupil-account links, and role/school denials.
- **Not verified:** PHP syntax only. Database aggregation, reconciliation against live ledgers, print layout, and role isolation require live MySQL/browser tests; the local MySQL service is unavailable. Invoices, discounts/scholarships, reconciliation workflows, and payment matching remain incomplete.

- **Arrears export follow-up:** authorized school finance users can download the same reversal-aware, school-scoped arrears rows as CSV. CSV formula-like values are prefixed to reduce spreadsheet formula injection risk. The test checklist now compares the export against the report and verifies role/school denial. Static validation only; runtime export and live data reconciliation remain unverified.


## Audit follow-up - Department Head scope

- Initial inspection showed that the existing department head column had no management workflow. The current increment adds role provisioning, subject mapping, and scoped scheme/lesson reviews. Department dashboards, workload overview, department teacher reports, and runtime verification remain incomplete.

## Current increment — Department Head academic scope (initial workflow)

- **Schema:** migration `20261113_department_head_scope.sql` adds the `department_head` account role and school-scoped mapping of academic departments to class subjects. A school/subject unique key prevents assigning one subject to multiple departments. Existing `departments.head_user_id` is used for the assigned head; no duplicate department entity was introduced.
- **Provisioning and assignment:** Directors, delegated school managers, and headteachers can create Department Head accounts. A new asynchronous academic-departments page lets authorized school managers assign an active Department Head linked to that school and map the department's class subjects. Changes are audited. Heads can view only their own department assignments.
- **Academic review:** planning lists expose mapped department schemes/lessons; server-side review checks require current mapping and school scope. Department Heads can approve/return submitted schemes and lesson plans for their mapped subjects. They do not receive broad leadership review rights or access to the school-wide academic reports page.
- **Navigation:** role-specific navigation routes Department Heads to academic departments and teaching plans; team access is redirected away.
- **Test checklist:** added account provisioning, mapping exclusivity, scoped review, school isolation, revocation, and audit checks.
- **Dashboard extension:** the page now summarizes pending scheme/lesson reviews, confirmed topic coverage, active teacher assignments, and averages from published examination results for mapped subjects only.
- **Not verified:** PHP/JavaScript static checks only. Migration application, dashboard query semantics, account lifecycle, concurrency on subject mapping, cross-school negatives, planning review flows, and browser behavior await MySQL/runtime tests. Department-level teacher reports and recommendations remain incomplete.


## Current increment - Lesson plans linked to the learning library

- **Schema:** migration `20261114_lesson_library_links.sql` adds a school-scoped join table from lesson plans to existing learning notes. A composite lesson/school foreign key prevents cross-school links; the source note is protected from deletion while referenced. The canonical schema includes the matching composite key and table definition.
- **Authoring:** the asynchronous planning catalog returns published central materials and published school notes. Teachers see only materials for assigned classes/subjects. The lesson form offers resources matching the selected approved scheme's class and subject while preserving the existing free-text materials field.
- **Validation and display:** server checks require published notes matching school, class, and subject, cap links at 20, and replace prior links only when a draft/returned lesson is saved. Linked titles appear on lesson cards. Audits record linked note IDs.
- **Test checklist:** added publication, matching, assignment, school-scope, update, and source-retention checks.
- **Not verified:** PHP/JavaScript static validation only. Migration application, SQL behavior, note scope, CRUD links, and browser tests await a running MySQL service.


## Current increment - Connected teacher report activity snapshots

- **Schema:** migration `20261115_teacher_report_activity_snapshot.sql` and canonical schema add an activity snapshot field to teacher reports.
- **Connected data:** report-period summaries now include scheduled and outstanding lesson plans, confirmed delivered lessons/periods, attendance summaries for the teacher’s active assigned classes grouped by status, plus attendance marks personally recorded by that teacher, teaching-record challenge/intervention counts, and exams in results-open or published state with result rows for an active assigned subject.
- **Persistence:** the server generates a snapshot on save/submit and stores it with the report; returning a draft for edits refreshes the snapshot. Submitted/reviewed reports retain the captured snapshot. Teachers may still add their own narrative, challenges, interventions, and recommendations.
- **QA:** added checks for date bounds, assignment and school scope, published/held assessment states, snapshot persistence/update, and review retention.
- **Not verified:** PHP/JavaScript static checks only. Snapshot queries and migration await live MySQL; counts are intentionally based on records attributable to the signed-in teacher and assigned subjects.

## Current increment - Configurable school grading scales

- **Schema:** migration `20261116_school_grading_scales.sql` and canonical schema add school/year/class scoped scale headers and ordered grade bands. Class ownership is enforced with a composite school/class foreign key.
- **Workflow:** leadership can create draft scales and publish them asynchronously. Inputs are validated for labels, 0–100 bounds, and overlapping ranges; creation and publication are audited. Published scales are immutable; revisions use a new draft. No grading cutoffs are presumed.
- **Reports:** academic reports select the latest published class scale when available, otherwise the latest school-wide scale for the year. Scores outside configured bands display as `Ungraded`.
- **Checklist:** added tests for permissions, band validation, class override, immutability, report output, auditing, and school isolation.
- **Not verified:** PHP/JavaScript static validation only. Migration and report/scale queries await MySQL; parent/pupil report-card grade integration is recorded in the next increment.

## Current increment - Grading scales in published report cards

- **Integration:** report cards now match each published score's class and academic year to the latest published class-specific scale, falling back to the school-wide scale. The grade displays beside the normalized mark; out-of-band scores show as `Ungraded`.
- **Access:** grading-scale readers see published scales only; leadership can also view drafts. Parent/pupil card access continues to require the existing guardian link or pupil account plus a published report card.
- **QA:** checklist now covers grade output, class precedence, ungraded marks, unpublished data hiding, and guardian/school isolation. Percentages are rounded to the stored 2-decimal band precision before matching.
- **Not verified:** PHP static checks only. Live grade selection, runtime portal authorization, and browser rendering await MySQL availability.

## Current increment - Pupil transfer, graduation, and reactivation

- **Schema:** migration `20261117_pupil_status_history.sql` and canonical schema add an append-only history of pupil status, effective date, optional note, and actor. Existing pupil status values were already present.
- **Workflow:** school leadership can transition active pupils to transferred or graduated, and reactivate former pupils. Transitions are row-locked, school-scoped, date-validated, audited, and kept in order; non-active statuses cannot be swapped directly.
- **History and access:** leaders can view status history asynchronously. Existing class, academic, attendance, and finance records are retained. Existing parent and pupil portal active-status checks stop access while the pupil is inactive and allow it again after an authorized reactivation.
- **QA:** checklist covers status lifecycle, history, invalid transitions, data retention, portal access, and scope denials. PHP syntax passed for all public PHP files and Node syntax passed for all JavaScript assets. Migration/schema table definitions match.
- **Remaining at this point:** editing and bulk enrollment were added in subsequent increments; database/browser verification remains incomplete.

## Current increment - Asynchronous pupil profile editing

- **Scope:** school leaders can asynchronously edit names, date of birth, day/boarding type, and registration contact details. Admission number and class placement stay outside this form; class changes retain the promotion/history workflow. Guardian portal links are not modified by registration-contact edits.
- **Integrity:** the endpoint validates membership and role, validates names/date/type/lengths, locks the school-scoped pupil row, updates linked active pupil-account display names after a name change, and audits changed field names without copying the values into the audit record.
- **UX/QA:** directory data patches in place after a successful response; duplicate submits are blocked and network/validation errors preserve entered values. Checklist now covers field validation, account-name sync, audit privacy, immutable fields, and scope negatives.
- **Not verified:** static syntax and browser-level form behavior pending. The MySQL connection remains unavailable; bulk enrollment also remains incomplete.

## Current increment - Atomic CSV bulk pupil enrollment

- **Template:** the existing pupil CSV template now has a school-membership check and includes the school admin role while retaining its established column layout.
- **Import:** leadership can upload up to 500 pupils in a CSV. The importer accepts the existing `Admission Number / Full Names / Class level / Stream / DOB / Day or Boarding / Parent/guardian name / Guardian phone number` template and an explicit first/middle/last name layout.
- **Validation/integrity:** the complete file is validated before writes, including required fields, class and stream membership, dates, scholar type, file/row limits, within-file duplicates, and existing school admission numbers. Any row error rejects the whole batch. A transaction inserts pupils, initial class-history records, and a non-PII batch audit entry together; unique-key races roll back the batch.
- **UX/QA:** CSV upload is asynchronous, reports row-level errors, and refreshes the pupil directory fragment on success. Checklist covers atomicity, class history, school isolation, malformed files, and role restrictions.
- **Not verified:** PHP/JavaScript static checks only so far; database transaction behavior and browser upload/refresh remain unverified while MySQL is unavailable.

## Current increment - Teacher role dashboard

- **Dashboard data:** the teacher overview now asynchronously shows active class-subject assignments, approved/completed lessons scheduled in the next 14 days, approved past-dated lessons awaiting confirmation, submitted teacher reports, and assigned examinations open for marks.
- **School scope:** multi-school teachers can switch among memberships. The JSON endpoint independently enforces the teacher role and school membership; its assignments, lessons, reports, and exams are bounded to that teacher and school.
- **UX:** empty states and error states replace generic counters. Shortcuts preserve selected school context for teaching plans, attendance, reports, and examinations. No polling or fabricated values are used.
- **QA:** added teacher-dashboard checks for source data, school switching/forgery, role scope, empty/error states, and links.
- **Not verified:** PHP/JavaScript syntax checks only; SQL semantics and rendered/browser interactions await MySQL availability. Other role dashboards remain outstanding.

## Current increment - Bursar role dashboard

- **Finance metrics:** the Bursar overview now asynchronously loads active pupil count, ledger-derived pupils with arrears and total outstanding balance, month-to-date payments less payment reversals, draft fee-structure count, and recent fee ledger entries.
- **Scope:** only Bursar accounts can call the endpoint. Each request rechecks membership in the selected school. The arrears query uses the same charge/payment/reversal signs as fee accounts and includes former pupils with balances.
- **UX:** multi-school Bursars can select a linked school; finance links keep that school context. Empty and error states do not substitute decorative totals.
- **QA:** checklist now covers ledger math, former pupils, reversals, school switching/forgery, role denial, and empty/error states.
- **Not verified:** PHP/JavaScript static checks only; live SQL and browser behavior remain unverified because MySQL is refusing connections. Director, academic leadership, HR, and stores dashboards remain outstanding.

## Current increment - Attendance reporting and teacher class scope

- **Reporting:** added an asynchronous, school-scoped attendance report with date-range, class, status, and daily summaries. The report contains aggregate counts only and keeps excused marks separate.
- **Authorization:** the new endpoint checks active sign-in, role, school membership, class membership, and teacher assignments. Teacher register class choices are restricted to assigned classes, and a manually supplied unassigned class is rejected before loading pupil data.
- **QA:** added checklist coverage for ranges, totals, aggregate privacy, assignment and school-scope negatives. PHP syntax passed for all public PHP files and `operations.js` passed Node syntax validation.
- **Not verified:** MySQL refused its connection, so SQL, role denial, and browser rendering have not been exercised. Attendance notifications remain outstanding.

## Current increment - HR role dashboard

- **Dashboard:** HR users now see asynchronous counts for active school staff, pending leave requests, contracts ending within 30 days, and active contract records past their end date, plus recent leave requests.
- **Scope:** school choices come from the signed-in HR user's memberships; every API request checks the HR role and selected school membership. Recent staff names and roles are rendered as text.
- **Connections:** dashboard shortcuts open the existing school-scoped leave and contract workflows.
- **QA:** added HR dashboard cases for source metrics, school/role denial, link context, and empty/error states. PHP and JavaScript syntax checks passed for the new endpoint/page client.
- **Not verified:** live SQL results and browser interaction remain unverified because MySQL is refusing connections. Director, academic leadership, and stores dashboards remain outstanding.

## Current increment - Head of Academics dashboard

- **Dashboard:** asynchronous school dashboard shows submitted schemes, lesson plans, teacher reports, and examinations awaiting review, plus confirmed lessons and periods delivered in the last 30 days.
- **Scope:** only Head of Academics can call the data endpoint; the selected school is revalidated against the user's membership. Coverage metrics come from confirmed teaching records, not scheduled lessons.
- **Connections:** review queue aggregates submitted academic items; shortcuts open teaching plans and examination workflows. Multi-school selection uses the user's existing memberships.
- **QA:** added checklist cases for metric sources, confirmed coverage, school/role isolation, queue rendering, and error states. PHP syntax passed for the dashboard page and endpoint; JavaScript syntax passed for the client.
- **Not verified:** database query execution and browser interaction remain unverified while MySQL is unavailable. Director and stores dashboards remain outstanding.

## Current increment - School leadership dashboard

- **Dashboard:** asynchronous school overview reports active pupils and recent enrollment, active staff, seven-day attendance rate, month net fee payments, outstanding balances, confirmed teaching activity, pending academic/HR/stores approvals, and low-stock items.
- **Data rules:** finance totals use the append-only ledger and reversals; attendance is based on recorded marks, excludes excused marks from the rate denominator, and shows no-data when there are no eligible marks; teaching activity counts confirmed records only.
- **Scope/connections:** only Director, School Manager, and Headteacher roles can call the endpoint, and every request validates school membership. Shortcuts carry the chosen school into existing fees, attendance, planning, and inventory workflows. Multi-school leadership users can switch among linked schools.
- **QA:** added checklist coverage for metric sources, attendance denominator, school/role isolation, link context, and errors. Project-wide PHP and JavaScript syntax checks passed after the dashboard was extended to Director, School Manager, and Headteacher roles.
- **Not verified:** live queries and browser behavior remain unverified because MySQL is unavailable. Notification workflows remain outstanding.

## Current increment - Storekeeper dashboard

- **Dashboard:** asynchronously shows inventory item count, combined units, threshold-based low-stock count, pending and approved stock requests, and recent stock movements.
- **Scope:** only Storekeeper accounts can call the endpoint; the selected school is rechecked against school membership. Movement rows join inventory items on both item and school IDs.
- **Connections:** dashboard links into the existing stock/request workflow; figures come from inventory records, requests, and movement history.
- **QA:** added checklist cases for source data, school-safe joins, role and membership denial, empty states, and errors. PHP syntax passed for all 62 public PHP files and JavaScript syntax passed for all 23 frontend assets.
- **Not verified:** database and browser behavior remain unverified because MySQL is unavailable. A parent/teacher message thread and a payment-confirmation SMS outbox with retry/status polling are implemented in code; additional notification triggers, configurable templates, delivery configuration, and runtime verification remain incomplete.

## Current increment - Homework and pupil activities

- **Schema:** added homework assignments and pupil submissions to the canonical schema and migration, with school-scoped assignment/submission relationships, one submission per pupil per assignment, optional learning-material linkage, and review feedback fields.
- **Workflow:** teachers create drafts or publish activities to their active class/subject assignments. Pupils access published activities using their active pupil-account link, submit/update responses until reviewed, and see teacher feedback. Teachers can view and review their own submissions; academic leadership can review within linked school scope. Parents see only assignment titles, subjects, due dates, and status summaries for pupils linked to their account; pupil response text is not shown. Parent portal now also shows published central and school learning materials filtered to each linked child's class.
- **Connections/security:** optional materials must be published and match the class. Pupil, school, assignment, teacher assignment, and reviewer scope are checked server-side. Assignment creation, submission, and review are audited.
- **QA:** added manual checks for role/school isolation, assignment validation, uniqueness, review lock, material link, audit records, and linked-child-only parent summaries/materials. PHP syntax passed for all 65 public PHP files, JavaScript syntax passed for all 25 assets, and canonical homework table definitions match the migration.
- **Not verified:** migration application, database constraints, and browser workflow remain unverified while MySQL is unavailable.

## Current increment - Weekly class timetable

- **Schema:** added timetable entries with class, optional stream, class subject, assigned teacher, weekday, time range, optional room, draft/published/archived status, and school-scoped indexes/foreign keys in the canonical schema and migration.
- **Workflow:** school leadership can create drafts, publish, and archive entries asynchronously. The API rejects class/stream/subject/teacher mismatches and checks time overlaps across the same class/stream and teacher. Class and teacher rows are locked during overlap check and insert.
- **Access:** teachers see only their own published periods; pupils see their active class and stream timetable; parents choose only from active children linked to their account. Sensitive changes are audited.
- **QA:** added checklist cases for conflict cases, role/school isolation, linked-child views, schedule ordering, and audit history. Timetable schema matches its migration; PHP syntax passed for all 67 public files and JavaScript syntax passed for all 26 assets.
- **Not verified:** timetable migration, MySQL locking/conflict behavior, and browser rendering remain unverified because the local database is unavailable.

## Current increment - Printable pupil fee statement

- **Statement:** authorized finance roles can print or save a pupil's complete fee ledger as a PDF from the browser. It includes pupil/school identity, transaction year/term, original and reversal entries, reasons, payment details, recorder, signed amounts, running balance, and net charge/payment totals.
- **Integrity/scope:** values are derived from the append-only school ledger using existing reversal signs. The route requires the user's school membership and verifies the pupil belongs to that school; inactive/former pupils remain available for historical balances.
- **Connection:** added a statement shortcut beside the pupil ledger in the accounting workflow; no transaction history is modified.
- **QA:** added manual checks to reconcile statement entries/running balance/totals and to test forged pupil/school IDs. PHP syntax checks are pending.
- **Not verified:** database-backed totals and browser print layout remain unverified while MySQL is unavailable. Invoice generation, discounts, and payment reconciliation remain incomplete.

## Current increment - School-scoped employee profiles

- **Schema:** added an employee profile entity linked separately to school membership and user account, with optional employee number, job title, department, and employment type. Employee numbers are unique per school; profile creation/update actors and timestamps are retained.
- **Workflow/access:** HR can create/update profile fields asynchronously. School leadership has read-only access. The directory excludes pupil/parent accounts and does not expose user phone/email or account credentials. Existing contract records remain separate.
- **Connections:** added staff profile navigation and a shortcut from the HR dashboard; profiles use the existing school team membership as the relationship boundary.
- **QA:** added checklist coverage for uniqueness, role write denial, school scope, and separation from users/contracts. PHP syntax passed for all 70 public files, JavaScript syntax passed for all 27 assets, and the profile schema matches its migration.
- **Not verified:** migration and browser behavior remain unverified because MySQL is unavailable. Staff attendance, contract renewal history, and in-app expiry alerts remained incomplete at that earlier increment.

## Current increment - Secure staff document management

- **Schema/storage:** added school-scoped employee document metadata in the canonical schema and migration. Uploads are restricted to PDF/JPEG/PNG, capped at 10 MB, MIME checked, named randomly, and stored in `storage/staff_documents` outside `public_html` with private file permissions.
- **Workflow/access:** HR can upload documents; HR and school leadership can list/download documents for school-linked staff. The page and API both enforce school scope and an allowlist of staff roles. Download is attachment-only with `nosniff` and `no-store`; uploads and audit metadata are written transactionally, with file cleanup if recording fails.
- **Connections:** the employee profile list now links to each staff member’s document page. Added manual QA cases for allowed formats, scope/role checks, storage isolation, audit records, and async states.
- **QA:** PHP syntax passed for all 72 public PHP files and JavaScript syntax passed for all 28 frontend assets. Canonical schema and migration definitions match. The protected staff page also filters non-staff targets before rendering profile names. `config/config.php` hash is unchanged. MySQL remains unavailable, so migration execution, database behavior, and browser workflow are not verified.


## Current increment - Contract renewal history

- **Schema:** added a nullable self-reference from each renewed contract to its predecessor, with a unique constraint preventing multiple direct renewals from the same record and a self foreign key. Added migration `20261122_contract_renewal_history.sql`; existing contracts remain valid with a null link.
- **Workflow:** the contracts workspace has an explicit Renew action. Renewal creates a new contract row, marks the previous row Renewed, links the records, and audits both the renewal and creation in one transaction. Renewal is limited to the same staff member and must start after the predecessor ends; a second renewal is rejected. Existing contract editing is retained for corrections.
- **QA:** added manual cases for date, identity, duplicate, audit, and school-scope checks. PHP syntax passed for all 72 public PHP files and JavaScript syntax passed for all 28 frontend assets; `config/config.php` remains unchanged.
- **Not verified:** MySQL is unavailable, so the migration and transaction behavior cannot yet be exercised against the database or browser-tested.


## Current increment - Staff check-in and check-out

- **Schema:** added a school-scoped employee attendance table with one check-in record per staff member per school day, optional check-out, actor references, indexes, and foreign keys; added migration `20261123_employee_attendance.sql`.
- **Workflow:** linked staff can record only their own check-in and check-out. Check-out requires an open same-day record. HR and school leadership can view a selected-date report for linked staff. The report distinguishes no record from a recorded check-in and does not infer absence.
- **Integrity/access:** school membership and allowed staff roles are checked server-side; duplicate daily check-ins and repeated check-outs are rejected. Writes and audit events run transactionally. The page and API are asynchronous; a navigation entry is available to staff roles.
- **QA:** added manual cases for duplicate and forged requests, role/school scope, audit atomicity, and no inferred absence. PHP syntax passed for all 74 public PHP files and JavaScript syntax passed for all 29 frontend assets; the migration DDL matches the canonical schema. Database and browser behavior remain unverified while MySQL is unavailable.


## Current increment - Staff workload overview

- **Data:** read-only metrics use active teacher assignments, published timetable periods and their scheduled minutes per week, plus submitted lesson plans awaiting review. No configured workload thresholds exist, so no capacity score is inferred.
- **Access/UX:** HR and school leadership can asynchronously view active staff within a linked school. The endpoint independently validates role and membership; the report has loading, empty, error and refresh states and is linked in the role navigation.
- **QA:** added checklist cases for source reconciliation, school/role isolation, and avoiding fabricated capacity metrics. PHP syntax passed for all 76 public PHP files and JavaScript syntax passed for all 30 frontend assets.
- **Not verified:** MySQL remains unavailable, so query results and rendered browser behavior cannot be confirmed.


## Current increment - Actionable contract expiry alerts

- **Workflow:** the HR dashboard now lists active contracts ending within 30 days or past their end date, with remaining/overdue days and a direct link to review renewal. It uses the existing school-scoped contracts and dashboard API.
- **Messaging boundary:** no SMS is sent. The configured SMS helper is currently limited to director credential delivery, so the alert stays in the authenticated HR dashboard and avoids exposing employment details through an unconfigured channel.
- **UX/QA:** alerts render asynchronously with empty and error states; names and dates are rendered as text. Added checklist cases for due/overdue rows, renewed-record exclusion, school scope and the renewal link.
- **QA:** PHP syntax passed for all 76 public PHP files and JavaScript syntax passed for all 30 frontend assets. `config/config.php` hash remains unchanged.
- **Not verified:** the database probe returned `DB_UNAVAILABLE`; contract alert query results and browser behavior are not verified.


## Current increment - Printable payment receipts

- **Workflow:** each payment ledger entry now links to a printable receipt with a stable system reference, school and pupil identity, amount, method/reference, academic year/term, recording time, and recorder. Reversed payments remain printable and are prominently marked with the reversal date and reason.
- **Connections/access:** receipt links are available both on initial ledger rendering and after asynchronous payment entry. The receipt page restricts access to authorized school finance roles and verifies school membership, payment type, pupil relationship, and school scope.
- **QA:** added checklist coverage for ledger reconciliation, cross-school/pupil access, required receipt details, and reversal status. PHP syntax passed for all 77 public PHP files and JavaScript syntax passed for all 30 frontend assets; `config/config.php` remains unchanged.
- **Not verified:** the configured database responds to a read-only query, but its current schema does not contain `school_fee_ledger` (along with other current schema requirements), so receipt data and browser print output cannot be verified until schema compatibility is reviewed and migrations are applied.


## Current environment finding - Finance runtime readiness

- A read-only connection check now succeeds against the configured database (`somaspac_shulelite2`). Information schema inspection shows that required current tables including `school_fee_ledger` are absent. No database writes or migrations were run.
- The database is reachable but not at the schema level expected by the current application. Finance runtime tests are therefore not meaningful yet. Configuration hardening remains deferred and `config/config.php` is unchanged.


## Current increment - Fee-structure invoices

- **Workflow:** published or archived fee structures with pupil-item assessments now expose an invoice register. Finance users can print an invoice per assessed pupil, with a stable school/structure/pupil reference and line items linked to the original ledger charges.
- **Integrity:** invoices identify charge reversals and show original amount, reversal adjustment, and net invoice charges. Current academic-term balance is reported separately because ledger payments are not allocated to a particular invoice. No new schema or financial policy was introduced.
- **Access/QA:** finance roles and school membership are checked on both register and invoice routes; invoice rows require a matching school, structure, pupil, assessment, and ledger entry. Added checklist cases for source rows, reversals, balance clarity, print output, and forged IDs.
- **QA:** PHP syntax passed for all 79 public PHP files and JavaScript syntax passed for all 30 frontend assets; no schema changes were required. `config/config.php` remains unchanged.
- **Not verified:** the configured database responds but lacks `school_fee_ledger`, so invoice query results and print behavior cannot be exercised until the database schema is reconciled with the application's current schema.


## Current increment - Traceable stocktakes

- **Schema:** added nullable before/after balances to inventory movements, with migration `20261124_inventory_balance_audit.sql`. Legacy movements remain readable with blank balance snapshots.
- **Workflow:** receipts, issues, approved request issues, and physical-count adjustments now record movement-level balances. A physical count adjustment requires a reason on both client and server; its entered quantity continues to mean the resulting on-hand count.
- **Audit/UX:** existing transactional audit records remain in place; movement history now displays before/after balances and labels physical counts clearly. Added checklist coverage for reconciliation and required adjustment notes.
- **QA:** PHP syntax passed for all 79 public PHP files and JavaScript syntax passed for all 30 frontend assets; `config/config.php` remains unchanged.
- **Not verified:** the configured database lacks `inventory_movements`, so the migration and movement behavior are not runtime-verified.


## Current increment - School suppliers and receipt linkage

- **Schema:** added `inventory_suppliers` with school-scoped uniqueness, optional contact details, active/inactive status, creator/updater references, and a supplier link on inventory movements. Migration: `20261125_inventory_suppliers.sql`.
- **Workflow:** Storekeeper and school-manager stock roles can add, deactivate, and reactivate suppliers. A receipt can optionally select an active supplier; supplier IDs are validated against the selected school and rejected on issues or physical-count adjustments. Movement history displays the linked supplier.
- **Integrity/access:** supplier changes are transactional and audited. Existing movements remain valid with a null supplier; no existing item or movement is deleted.
- **QA:** added checklist coverage for cross-school suppliers, status changes, and movement-type constraints. PHP syntax passed for all 79 public PHP files and JavaScript syntax passed for all 30 frontend assets; supplier table DDL matches the canonical schema. `config/config.php` remains unchanged.
- **Not verified:** the configured database lacks `inventory_movements`, so supplier migration and movement behavior are not runtime-verified.


## Inventory categories increment

- **New:** school-scoped inventory categories with unique names, active/inactive lifecycle, creator/updater attribution, and audit events. Deactivation preserves assigned item categories; inactive categories cannot be assigned to new or recategorized items.
- **Connected:** stock item creation supports optional active category assignment. Existing items can be recategorized from the stock list; inactive category assignments remain selected and visible until intentionally changed.
- **Schema:** canonical schema and migration `20261126_inventory_categories.sql` add categories and nullable composite school-scoped category reference on inventory items. Existing items remain uncategorized.
- **QA checklist:** added checks for category scope, uniqueness, lifecycle, initial assignment, and reassignment of existing items. PHP syntax and frontend JS syntax checks passed for the changed components.
- **Runtime:** database migration not applied; database remains behind schema. Runtime feature checks remain outstanding. `config.php` was not changed.


## Department workload connection

- **Improved:** the academic departments dashboard now reports each mapped teacher's active assigned class-subject count, published timetable periods and scheduled minutes per week, and submitted lesson plans awaiting review.
- **Scope:** queries are constrained to the selected school and mapped academic department; Department Heads only receive their own department rows. No synthetic workload threshold or capacity score is inferred.
- **QA:** added manual reconciliation and Department Head scope checks. No schema change was required.
- **Not verified:** database-backed query results and browser behavior remain unverified because the configured database schema is behind the application schema.


## Pupil learning progress overview

- **New:** the learner dashboard groups published assessment rows by subject and exam, aggregates marks earned and available across that exam's assessments, and shows a plain percentage without applying school grading bands or comparing unlike exams.
- **Connected:** the dashboard also summarizes currently published and recent class homework as assigned, submitted, and reviewed, alongside existing results, attendance, report cards, learning materials, and holiday packages.
- **Access:** progress queries derive school and pupil IDs from the active signed-in pupil account and retain published-result/class/subject filters.
- **QA:** added checklist cases for calculation reconciliation, homework counts, unpublished/cross-pupil/cross-school isolation, and meaningful empty states. No schema change was required.
- **Not verified:** database-backed totals and rendered browser behavior remain unverified until the installed database schema is reconciled.


## Teacher report attendance scope

- **Corrected:** report-period summaries now include class attendance across the teacher’s active assigned classes, regardless of which authorized staff member recorded the register. They continue to include a separate count of attendance marks personally recorded by the teacher.
- **Scope/integrity:** aggregates are school/date scoped and use `EXISTS` for assignment matching to avoid multiplying a pupil/day mark when a teacher has multiple subject assignments in a class. No pupil-level attendance details are exposed in the report summary.
- **Compatibility:** stored report snapshots keep their existing attendance fields; newly generated snapshots add explicit assigned-class fields. Older snapshots are labeled as not captured for assigned-class scope.
- **QA:** added class/period reconciliation, assignment-scope, no-duplicate and older-snapshot checks. No schema change was required.


## Controlled published-result corrections

- **New workflow:** authorized result editors can request a score correction on a published exam, with a required reason. Ordinary edits remain locked after publication. A different authorized academic reviewer must approve or reject; rejections require a review note.
- **Integrity/audit:** the request stores original and proposed scores. Approval locks the request, exam, and result; verifies the score has not changed and remains within the maximum; updates the result and writes the decision and before/after audit events in one transaction. Pending requests are serialized by locking the result row.
- **Access/UI:** requesters can see their requests; designated academic reviewers see school-scoped requests. The published results page uses an asynchronous request/review interface and refreshes the displayed score after approval.
- **Schema:** canonical schema and migration `20261127_result_corrections.sql` add the append-preserving correction request history table.
- **QA:** added authorization, score bounds/precision, separation of requester/reviewer, duplicate pending request, transaction/audit, and async failure cases.
- **Not verified:** migration and database-backed workflow remain untested because the configured database is behind the application schema.


## AI question generation to question-bank drafts

- **Connected:** the note-based AI generator requests a strict structured question payload asynchronously and renders it as a readable question set and answer key when valid, with loading and error feedback and no full-page navigation. A valid set can be imported into a selected school, class, and subject.
- **Integrity:** the question-bank endpoint revalidates school membership, class/subject relationship, teacher assignment, question count, field types/lengths, type/style mapping, difficulty, and marks. A unique actor/school import key makes retries idempotent. It saves all entries in one transaction with `source='ai'` and `status='draft'`; no question is auto-approved or published.
- **Workflow:** users continue editing, submitting, reviewing, approving, publishing, and selecting imported questions through the existing question-bank/exam builder paths. Invalid structured model output remains visible/copyable but cannot be imported.
- **Schema:** existing question-bank `source` enum supports AI drafts; migration `20261128_ai_question_import_batches.sql` adds an idempotency record so retrying the same import key returns the original draft IDs.
- **QA:** added scope, transaction rollback, validation, duplicate-submit and draft-review lifecycle checks.
- **Not verified:** OpenRouter output shape, database writes, school/teacher authorization and browser flow remain unverified in this environment.


## Asynchronous AI question generation

- **Improved:** note-based generation now submits through Fetch and returns the same structured result envelope as the shared API helper. The page stays in place and shows a busy state, provider/validation errors, generated questions, copy action, and the import workflow.
- **Compatibility:** the ordinary POST response remains available if JavaScript is unavailable; OpenRouter settings continue using the existing save flow.
- **QA:** the AI import checklist now verifies asynchronous loading, failure feedback, and no full-page navigation. Static syntax checks cover the new client and server response branch.
- **Not verified:** end-to-end provider latency, response parsing, browser behavior and database import remain unverified in the local environment.


## Traceable inventory stocktake sessions

- **New workflow:** Storekeepers and school managers can snapshot school inventory, save physical counts, submit a completed count, and receive independent manager review. Applying a count updates changed balances and writes before/after adjusted movements and audit events in one transaction. Rejections require a reason.
- **Integrity/access:** Sessions and lines are school scoped; item references include the school in a composite foreign key. New items added after the snapshot block submission. Creator/reviewer separation and one-way status transitions prevent self-approval and duplicate application.
- **UI:** Added an asynchronous stocktake screen linked from Stock items with session list, count entry, status review, and manager actions.
- **Schema:** canonical schema and migration `20261129_inventory_stocktake_sessions.sql` add sessions, lines, and the composite inventory-item key.
- **QA:** added checklist cases for counts, concurrent additions, reviewer separation, scope, transactional rollbacks, movement history, and repeated review. `config/config.php` remains unchanged.
- **Not verified:** database migration and runtime behavior remain pending; configured local schema is behind.


## Parent–teacher messaging

- **New:** linked parents and currently assigned teachers can open school-scoped conversations associated with an active pupil and send asynchronous messages with client request keys that make retries idempotent. Parent recipient choices are limited to teachers assigned to the child’s current class; teacher choices are limited to linked guardians in currently assigned classes.
- **Access:** each read/send revalidates the guardian-pupil link or the teacher’s active assignment and school membership. Messages are participant-only, incoming messages are marked read when opened, and sent messages/conversation creation are audited. Message content is rendered as text.
- **UI:** added a shared message page and role-specific navigation for parents and teachers.
- **Schema:** canonical schema and migration `20261130_parent_teacher_messaging.sql` add school-scoped conversations and messages with composite scope constraints.
- **QA:** added checklist coverage for recipient authorization, participant access, revocation, CSRF/session behavior, and asynchronous error/empty states. No external SMS integration or credentials are involved.
- **Not verified:** migration execution, database-backed authorization and browser behavior remain unverified in the local environment.


## Event based SMS outbox foundation

- **Connected event:** recording a school fee payment now queues a generic receipt-available SMS for active, linked guardians whose `receives_notifications` preference is enabled and who have a phone on their parent account. The text avoids payment amounts and pupil identifiers. The outbox row is inserted in the same transaction as the fee ledger entry, so failed payment writes cannot create orphan notifications.
- **Reusable adapter:** added a small template registry and SomaSMS transport adapter that reads the existing credential helper without changing `config.php`. Delivery work is handled by CLI worker `bin/process_sms_outbox.php`; failed sends retry with backoff up to four attempts, accepted message IDs are polled for provider delivery status, and guardian link/consent/account/phone are rechecked before each send.
- **Integrity:** event/source/recipient uniqueness prevents duplicate queue rows; the payment ledger remains the source of truth. The worker was not run and no outbound SMS was sent during development.
- **Schema:** canonical schema and migration `20261201_school_sms_outbox.sql` add a school-scoped delivery outbox.
- **Operations:** once configured and migrated, schedule `php bin/process_sms_outbox.php` from the project root to process queued notifications.
- **Not verified:** provider credentials, live delivery, queue retries, report polling, and database behavior require migration plus controlled integration testing. Absent/late attendance, published exam results, parent/all-audience school announcements, and explicitly requested fee reminders are connected; contract-expiry delivery remains unconnected.


## Attendance alert connection

- **Connected event:** the class register queues an SMS alert for absent or late marks within the same transaction as attendance and audit writes. The reusable template does not include pupil name, status history, or other sensitive details. Present and excused marks do not trigger alerts.
- **Delivery check:** before sending, the CLI worker verifies the attendance row still represents an absent or late mark; corrected records are cancelled instead of sending a stale alert. Guardian link, preference, account status, and current phone are also checked.
- **QA:** added manual checks for trigger states, deduplication, transaction behavior, scope, and correction before send. No outbound message was sent.
- **Not verified:** database-backed register integration and provider delivery remain pending migration and controlled integration testing.


## Results and announcement SMS triggers

- **Exam results:** publishing a school exam queues a generic result-available SMS for each opt-in linked guardian of active pupils who have a result row in that exam. The worker rechecks that the exam is still published and a matching result remains before delivery. Marks and pupil identifiers are not sent.
- **Announcements:** publishing a non-expired all-school or parent-audience notice queues one generic announcement SMS per opted-in linked guardian, regardless of the number of linked children in that school. The worker rechecks publication, audience, expiry, account, preference, link, and current phone before sending.
- **Integrity:** both event queues participate in their publish transactions and use event/recipient uniqueness. No message is sent during authoring or publication requests; only the configured CLI worker sends queued notifications.
- **QA:** added checklist cases for event/status audience gating, multiple children, stale event cancellation, transactional writes, and duplicate retries. No external provider request was made.
- **Not verified:** database writes, report-provider responses, and live delivery remain unverified until migration and controlled integration tests. Contract-expiry delivery remains unconnected.

## Manual fee reminder trigger

- **Connected workflow:** an authorized finance user can queue a generic reminder from an active pupil account only when its all-term ledger balance remains positive. The event is keyed to the latest ledger row, so repeated requests for that same source are idempotent; no automatic schedule or reminder cadence is assumed.
- **Privacy/integrity:** only active linked guardians who opted in and have a phone are queued. The worker rechecks that the source ledger entry remains in scope, the pupil is active, and a positive balance remains before delivery; settled or inactive accounts are cancelled. The generic message contains no balance or pupil identifiers.
- **Audit/QA:** queuing is asynchronous and audited in the same transaction as the outbox writes. The manual checklist covers role and school denials, opt-in, duplicates, settlement cancellation, and delivery boundaries.
- **Not verified:** database transaction behavior, browser interaction, and controlled delivery remain pending live MySQL/browser tests. No SMS was sent during implementation.
- **Static validation after this increment:** PHP syntax passed for all 86 PHP files under `public_html` and `bin`; Node syntax passed for all 35 JavaScript assets and the `dev.html` inline checklist script. `config/config.php` SHA-256 remains `97817B66039004DF01E644B0CF0BCEB568FD5F0E78225BD1F8F48E01802EEDB1`.


## Teacher report print output

- **Improved:** teachers and authorized academic reviewers can open a saved report in a clean print layout and use the browser's print or Save as PDF workflow. The document includes the saved activity snapshot, teacher narrative fields, report status, and reviewer feedback when present.
- **Safety:** report text is HTML-escaped before it is written into the print document. The action loads the saved report through the existing authenticated, school-scoped API; no separate export route or permission path was added.
- **QA checklist:** added a manual print check for snapshot completeness, feedback, and markup-as-text handling.
- **Not verified:** print rendering and browser popup behavior require browser testing. Word export and automated PDF generation remain incomplete.
- **Static validation:** PHP syntax passed for all 86 PHP files under `public_html` and `bin`; Node syntax passed for all 35 JavaScript assets. `config/config.php` SHA-256 remains `97817B66039004DF01E644B0CF0BCEB568FD5F0E78225BD1F8F48E01802EEDB1`.
- **Checklist update:** `public_html/dev.html` now includes a cross-phase release gate covering migration/runtime verification, the connected academic journey, finance/inventory/staff reconciliation, guardian/learner isolation, controlled SMS testing, asynchronous security controls, product boundaries, and truthful phase closure.
- **Checklist update:** `public_html/dev.html` also covers finance-initiated fee reminders, including authorization, opt-in, duplicate prevention, settlement cancellation, and asynchronous audit behavior.


## Department teacher activity reporting

- **New:** the Department dashboard now provides an asynchronous date-range report by department and teacher, showing planned lessons, confirmed lessons, periods delivered, and submitted/approved teacher report counts.
- **Scope:** the activity totals are derived from schemes, lesson plans, teaching records, active assignments, mapped academic subjects, and the selected school. Department Heads are restricted to departments they currently lead. No teacher narrative is exposed because existing reports are teacher-wide rather than subject-scoped.
- **Validation/checklist:** dates are checked server-side and limited to 366 days. `public_html/dev.html` includes period, role, school, and narrative-scope checks.
- **Not verified:** SQL execution, cross-department authorization, date boundaries, and browser behavior require database/browser QA. No schema change was needed.


## Published academic report analysis

- **Improved:** academic reports now show a grade-distribution table using the published class grading scale or school-wide fallback, counting scores outside configured ranges as Ungraded. Percent values are rounded to two decimals before grade-band matching.
- **New analysis:** a term trend table compares published exams with the same class, subject, academic year, term, and assessment label. The report continues to exclude unpublished exams/results and uses existing exam visibility scope.
- **Checklist:** added grade reconciliation, term boundary, teacher assignment/delegation, async navigation, and empty/error-state checks.
- **Not verified:** database query results and browser navigation require live MySQL/browser QA. No grading thresholds or policies were created; existing published scales remain authoritative.


## Current increment — Stream-aware curriculum coverage

- **New:** lesson plans can optionally target a school class stream; unassigned lessons remain class-wide. Stream dropdown data is scoped by the selected school and selected scheme class.
- **New:** stream activity view lists scheduled lessons and periods from confirmed teaching records, with teacher, department-head, assistant academic, and leadership scope checks.
- **Database:** migration `20261202_lesson_stream_coverage.sql` adds a nullable stream reference and lookup index; canonical schema updated. The endpoint verifies that a selected stream belongs to the lesson scheme class in the same school.
- **Checklist:** added cross-school stream rejection, stream isolation, role scope, and confirmed-teaching cases in `public_html/dev.html`.
- **Not verified:** migration remains unapplied because the connected database is not confirmed disposable/backed up. The UI, SQL execution, authorization, and cross-school tests remain pending.


## Latest static validation

- PHP syntax: **passed**, all 86 PHP files in `public_html` and `bin`.
- JavaScript syntax: **passed**, all 35 assets and the inline `dev.html` checklist script.
- `config/config.php` SHA-256 unchanged at `97817B66039004DF01E644B0CF0BCEB568FD5F0E78225BD1F8F48E01802EEDB1`; hardening remains deferred.
- Runtime: **not run** against the connected database. Do not apply pending migrations until it is confirmed disposable or a verified backup exists.


## Current increment — Word-compatible academic report exports

- **New:** teacher reports and pupil report cards can be downloaded as Word-compatible `.doc` files generated from escaped report content. Teacher exports include the saved activity snapshot, narrative sections, status and review feedback. Report-card exports omit navigation, filters, print controls and staff comment forms.
- **Access:** report cards reuse the existing authorized page data, so parent/pupil exports contain only the published card already visible to their account.
- **Checklist:** added export completeness, markup-as-text, and guardian/pupil scope checks in `public_html/dev.html`.
- **Not verified:** Word rendering and actual document layout require manual Microsoft Word/LibreOffice review; no database change was needed.


## Current increment — Staff contract expiry notifications

- **Connected:** the SMS CLI worker queues one generic alert per active staff contract ending within 30 days, for an active staff account linked to the same school with a usable phone. A unique outbox event prevents repeat queueing for the same contract and recipient.
- **Delivery safety:** before sending, the worker rechecks contract status/date, school membership, staff account status, recipient identity, and phone. Renewed, ended, or out-of-window contracts are cancelled. The message body does not include the staff name, contract terms, or expiry date.
- **Configuration:** uses the existing outbox and SomaSMS adapter; no web request sends SMS and no `config.php` change was made.
- **Checklist:** added controlled-recipient, duplicate, stale-contract, sensitive-content and delivery-state cases.
- **Not verified:** do not run the worker against the connected database/provider until test database and credentials are confirmed. Runtime SMS delivery and retries remain untested.


## Current increment — Examination publication readiness

- **New:** academic reviewers can view an asynchronous preflight count of active pupils, pupils with results, missing pupils, and invalid score rows.
- **Guardrails:** publication blocks when there are no results or any score is negative, exceeds its maximum, or has a nonpositive maximum. Missing results require a reviewer reason of at least 10 characters. Counts and the reason are stored in the exam audit event; publication still locks ordinary edits.
- **Rationale:** missing rows can represent legitimate absences, so the system does not invent an absence or grading policy; an authorized reviewer explicitly accounts for incomplete coverage.
- **Checklist:** added empty/incomplete/invalid set, audit, role-scope, and notification recipient checks.
- **Not verified:** database-backed preflight, publication transaction, browser interactions and audit contents remain untested pending a safe test database.


### Isolated migration verification

- PDO connected to the configured local MySQL server; `SHOW GRANTS` confirmed the local development account can create isolated schemas.
- Created `somaspac_shulelite2_codexqa_20261022` only after confirming that exact schema name did not exist. Imported `database/schema.sql` into it (73 tables), removed the stream column to model the pre-migration state, applied `20261202_lesson_stream_coverage.sql`, and verified the column and foreign key.
- The disposable schema was dropped in cleanup. The configured `somaspac_shulelite2` database was not modified. This validates schema load and the new stream migration only; it does not certify all migrations or authenticated browser workflows.
- Static checks after this increment: PHP syntax passed for all 86 PHP files in `public_html` and `bin`; JavaScript syntax passed for all 35 assets and the inline `dev.html` checklist script. `config/config.php` remains unchanged.


## Current increment — Phase 1 AI planning, lesson editing, and exports

- **AI scheme drafts:** the async planning API can return 2–20 structured topic drafts for a school-scoped class/subject and term. Each row is validated and returned to the form for editing; nothing is saved or approved automatically.
- **AI lesson drafts:** the API only drafts from an approved, school-scoped scheme topic and checks teacher assignment. Lesson objective/activities fields are validated and returned to editable form inputs; it does not mark teaching complete.
- **Provider controls:** reuses the configured encrypted OpenRouter key and model, uses a bounded fallback chain, audits successful draft requests, and caps successful calls at five per user per ten minutes. No pupil data is sent.
- **Editing:** teachers can now reopen and edit their draft/returned lesson plans, including stream and linked learning-library items. Existing server-side status/ownership checks remain authoritative.
- **Documents:** schemes and lesson plans now offer Word-compatible `.doc` downloads and print/Save as PDF, with escaped content and lesson stream/resources.
- **Checklist:** added AI failure/scope/throttle, draft-only, edit authorization, and document completeness cases.
- **Not verified:** provider requests, browser UX, generated content quality, and document rendering require configured AI credentials and manual/browser testing.


## Current increment — Phase 1 department reporting and review

- **Schema:** added `department_reports` in migration `20261203_department_reports.sql` and the canonical schema. Reports retain school/department scope, author, period, activity snapshot, narrative, recommendations, status, and reviewer feedback/history fields; report writes are audited.
- **Workflow:** Department Heads can save drafts and submit reports only for currently assigned academic departments. School academic leadership can approve or return submitted reports, with return feedback required. Returned reports can be edited and resubmitted; approved reports are locked by status.
- **Privacy:** activity snapshots are calculated from subjects currently mapped to that department. Department Heads can read reports only for their assigned departments. Teacher-wide narratives remain separate and are not exposed through department reports.
- **UI and checklist:** added asynchronous department report authoring, listing, snapshot display, edit, and review controls; `dev.html` now covers submission, privacy, return/resubmit, approval, validation, and audit cases.
- **Verification:** PHP/JavaScript static syntax checks pass. Migration execution and authenticated MySQL/browser role journeys remain pending, so Phase 1 is implementation-complete but not release-verified.


### Phase 1 verification update

- Static validation passed for 86 PHP files, 35 JavaScript assets, and the inline `dev.html` checklist script.
- Isolated MySQL validation loaded the canonical schema, applied `20261203_department_reports.sql` after removing that table, then verified the 16-column table and four foreign keys. The disposable database was removed.
- Read-only verification confirmed the connected school database remains at its original 32 tables and has no `department_reports` table. `config/config.php` hash is unchanged. No school data or configuration changes were made by the QA check.
- Remaining release evidence: authenticated browser journeys for planning, reports, role boundaries and cross-school denial; configured AI provider behavior; document rendering and user-facing accessibility/usability review.


## Current increment — Phase 3 finance and stores completion

- **Fee discounts:** added a finance-role-only endpoint for reasoned discounts against an active pupil's selected year and term. It locks the pupil row, prevents discounts above the outstanding term balance, writes an append-only `discount` ledger entry and audit record, updates balances and statements, and allows a controlled compensating `discount_reversal`.
- **Payment reconciliation:** added CSV statement import (up to 1,000 rows / 5 MB), exact reference/amount auto-match suggestions, same-school manual receipt matching within seven days, duplicate prevention, reasoned exclusions, completion controls, history, and audit entries. Reconciliation never inserts or edits pupil ledger payments.
- **Inventory valuation:** added receipt unit costs and a clearly labelled latest-receipt-cost estimate to inventory items and the Stores dashboard. Issue/stocktake movements preserve the cost snapshot. Items with positive legacy quantity and no receipt cost are counted as unvalued rather than assigned invented costs.
- **Schema:** migration `20261204_fee_discounts_and_reconciliation.sql` extends the ledger type, adds reconciliation batch/line tables, and adds receipt cost fields. Matching structures are represented in `database/schema.sql`.
- **Checklist:** added Phase 3 cases in `public_html/dev.html` for discount permissions and balance propagation, CSV matching/duplicates/exclusions, ledger immutability, inventory cost evidence, legacy unvalued stock, and operational regressions.
- **Security:** new finance endpoints enforce active sessions, role checks, school membership, CSRF for writes, transaction locking, audit records, amount/date boundaries, and unique receipt matching. No changes were made to `config.php` or the configured school database.
- **Verification:** PHP syntax passed for all 89 files under `public_html` and `bin`; JavaScript syntax passed for all 36 assets; the inline `dev.html` script parsed and the Phase 3 checklist section is present. The canonical schema imported into a temporary isolated database with 76 tables. The new migration passed against a simulated pre-migration schema. Isolated smoke checks confirmed fee balance math across charge/payment/discount/reversal (KES 45), duplicate receipt matching is blocked, and the latest-receipt stock estimate calculates correctly (KES 25). All temporary databases were dropped. The configured school database remains at 32 tables and was not written to. Authenticated browser workflows, real CSV review, permission negatives, and HR/finance/store regression journeys remain release gates; Phase 3 is source-complete but not release-verified.

## Current increment — Phase 4 parent, pupil, and holiday learning completion

- **Existing connected workflows audited:** parent and pupil account links, parent multi-child view, attendance and fee summaries, published results/report cards, learning materials, homework assignment/submission/feedback, audience-filtered announcements, published timetables, parent/teacher messaging, and holiday package authoring/review/publication/progress already existed. These were preserved.
- **Corrected:** parent/pupil report-card period selection now recomputes available terms after selecting a different academic year, so the available period list and selected report stay aligned.
- **Security/scope:** learner-facing holiday package content now joins only published learning notes that match the package class/subject and central-or-school visibility, and only published questions for the package school/class/subject. Staff package detail uses the same restrictions. Publishing an already-expired package is rejected.
- **Checklist:** Phase 4 role QA now covers multiple children/guardians, account and link revocation, cross-school/forged IDs, published-result isolation, parent-vs-pupil package permissions, package scheduling and expiry, linked content scope, asynchronous error/empty states, and print/mobile review.
- **Access-policy decision:** package content is available when published and within its schedule. Optional paid entitlement has no defined school collection/entitlement policy in the existing system; no platform subscription or pupil fee ledger is repurposed as package payment. Resolve school policy before enabling paid access.
- **Verification:** runtime checks against authenticated parent/pupil accounts, destructive/no-leak authorization probes, and browser/mobile/print checks remain release gates. No migrations or configured school database writes were needed for this increment. `config/config.php` remains untouched; SomaBus remains excluded.
## Current increment — Phase 5 integrations and refinement completion

- **Notification audit:** the existing event-driven outbox covers payments, absent/late attendance, published exam results, parent/all-school announcements, finance-requested fee reminders, and staff contract expiry. Templates are centralized and generic; the SomaSMS transport is isolated from request handlers. Delivery attempts and provider status are retained in the school outbox.
- **Worker corrections:** fee-reminder revalidation now uses the current ledger balance model including discounts and discount reversals. Exam-result alerts are cancelled when a pupil becomes inactive before delivery. Provider states such as `sent` remain accepted/pending; only explicit delivered/success states are marked delivered.
- **SomaTokeo boundary:** added a versioned JSON Schema and integration guide in `integrations/somatokeo/`. The contract limits payloads to published academic scores with opaque institution/learner references. No endpoint, transport, credentials, or duplicate academic engine was introduced. The exchange requires school authorization, approved mappings, a lawful purpose, secure transport, and audit/replay controls before activation.
- **Checklist:** Phase 5 checks now cover discounted arrears, inactive pupils, provider status classes, duplicate/concurrent workers, stale claims, event/recipient revalidation, SomaTokeo contract acceptance/rejection, keyboard accessibility, mobile/slow-network states, pagination/polling, and release migration discipline.
- **Verification:** PHP syntax passed for all 91 PHP files under `public_html` and `bin`; JavaScript syntax passed for all 37 assets; the inline `dev.html` script and SomaTokeo schema JSON parsed successfully. No SMS worker was run, no live message was sent, and no configured school database was written. The canonical schema imported into a disposable database and `20261205_school_sms_templates.sql` applied successfully; that database was dropped. Provider concurrency/status behavior and browser accessibility/performance remain release gates. `config/config.php` was not modified; SomaBus remains excluded.
- **SMS configuration:** added `school_sms_templates` migration and canonical schema definition, an audited leadership-only settings API/page, and a paginated delivery view. Template text is plain static copy with no variable placeholders; defaults remain available, reset is supported, and queued messages retain their saved body.
- **API:** added `public_html/api/school_sms_templates.php` (`GET templates`, `GET deliveries`, `POST save/reset`) with school membership, leadership role, CSRF, audit, and bounded pagination checks.
## Current correction — director school access

- **Fixed:** the director dashboard now recognizes legacy schools created by the signed-in, active director when their membership row is missing. It restores a manager-scoped membership once, writes an audit event, then loads dashboard data through the normal school-membership path.
- **Safety:** restoration is limited to schools whose schools.created_by matches that director account; it does not link schools created by other users. config/config.php and the configured database were not changed.
- **Verification:** php -l public_html/index.php and the dev.html inline JavaScript syntax check passed. Database-backed and authenticated browser checks remain pending; the Director QA checklist now covers the legacy-link case.

## Current correction — core class and subject catalog

- **Changed:** System Admins and Sub Admins can rename core classes and subjects and remove them with an × control on the Academics catalog. The existing page-level and server-side role gate remains in force; operations are asynchronous and CSRF-protected.
- **Data handling:** edits are audited and duplicate names are rejected by existing unique constraints. Removing a core item clears only school-to-core mapping references via the existing ON DELETE SET NULL relationships; school-local class/subject names and operational records remain. Removing a core class also removes its catalog subjects through the existing catalog cascade.
- **Checklist:** System Admin and Sub Admin cases now include rename/remove, authorization, audit, duplicate, mapping, preservation, and async UI checks in public_html/dev.html.
- **Verification:** php -l public_html/academics.php and inline JavaScript syntax checks for the Academics page and dev.html passed. Database-backed workflow and browser checks remain pending; no migration or configured database change was needed.

## Current correction — learning-material catalog selectors

- **Changed:** central material forms now search only system core classes and show core subjects for the selected class. School teaching staff now see school-edited class/subject pairs constrained to their active assignments and school memberships.
- **Validation:** central note create/edit rejects pairs absent from the system catalog; staff note creation requires the pair to exist in the school catalog and an active assignment. Existing consumers continue to receive the established class/subject names.
- **Checklist:** System Admin and Teacher QA cases in public_html/dev.html cover searchable role-specific catalogs and forged/stale values.
- **Verification:** php -l public_html/notes.php passed; both inline JavaScript blocks passed 
ode --check. Database-backed and authenticated browser checks remain pending; no schema or config change was made.


## Current correction — Learning Material subtopic

- **Changed:** Learning Materials now use `subtopic` in place of the note `title`, with the field placed after `topic` in the canonical `learning_notes` schema and authoring forms.
- **Data preservation:** added `database/migrations/20261206_learning_note_subtopic.sql` to rename the existing column in place, retaining all current values as subtopics. The migration has not been applied to any configured database.
- **Connections:** updated Learning Materials, AI question context, lesson resource selection, homework materials, holiday packages, and parent/pupil displays to read the renamed field. Other entities such as homework assignments and holiday package items retain their own `title` fields.
- **Checklist:** added verification for the field order, preservation migration, and connected material consumers to `public_html/dev.html`.
- **Verification:** source syntax and reference checks are in progress; database-backed migration and authenticated workflow checks remain pending. `config/config.php` was not changed.


## Current correction — Learning Material visibility

- **Teacher scope:** the Learning Materials page now shows a teacher only school notes matching their active assigned class/subject and central curriculum notes matching those assignments, including mapped core catalogs. The homework, holiday-package, and AI question note catalogs and generation endpoint use the same teacher scope.
- **Leadership scope:** Headteachers and Directors see central curriculum notes plus school notes for schools where they have a membership; they do not receive another school's staff notes.
- **Checklist:** updated Teacher, Head of School, and Director cases in `public_html/dev.html` for relevant-note visibility and school isolation.
- **Verification:** PHP syntax checks passed for `notes.php`, `ai_questions.php`, `api/homework.php`, and `api/holiday_packages.php`. Authenticated role and database-backed scope checks remain pending.


## Current correction — AI multiple-choice questions

- **Generator:** added Multiple choice as an AI question section. Generation requires exactly four distinct choices and an answer that matches one choice; the printable/copyable question output labels the choices.
- **Question bank:** AI import now stores those choices in the existing `question_bank.options_json` column and saves the item with `multiple_choice` type as a draft for normal review.
- **Checklist:** updated the AI question workflow check in `public_html/dev.html` to cover option validation and import.
- **Verification:** PHP syntax checks passed for the generator and question-bank API. Live AI generation and database-backed import remain unverified.


## Current correction — AI question count selection

- **Changed:** users can choose section counts totaling 1–100 questions, instead of the previous fixed 30-question cap. The displayed total, add-section behavior, input validation, generation endpoint, and question-bank draft import limit are aligned.
- **Generation:** increased the provider request timeout to allow larger sets time to finish; generated and imported question counts must still match the requested section totals.
- **Checklist:** added verification for user-selected totals, exact generation/import count, and rejection above 100 to `public_html/dev.html`.
- **Verification:** PHP syntax checks passed for the AI generator and question-bank API. Large AI response latency and live imports remain unverified.
