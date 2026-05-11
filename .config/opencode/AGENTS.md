# Service Workflows Team Agent Guide

This guide provides essential information for AI agents working with the Service Workflows team. We build and maintain the post-order workflow platform — the systems that power customer and agent resolution flows (Report a Problem, Returns, WIMS, and more) across Wayfair.

---

## Extended Context

Detailed reference material lives in `/Users/ec825m/agent-context/`. Load these files when the task at hand requires them — do not load everything upfront.

| Directory | What's inside | When to read |
|---|---|---|
| `agent-context/runbooks/` | Operational runbooks for known recurring issues with fix scripts | Investigating a production incident, debugging cold transfer failures, duplicate submits, or SPDB corruption |
| `agent-context/testing/` | Playwright workflow traversal guide; request replay onboarding guide | Automating workflow testing in Storybook; adding request replay to a new workflow |
| `agent-context/known-issues/` | Documented bugs with root causes and proposed fixes | Before touching request replay code or HEIC image handling |
| `agent-context/queries/` | Annotated BigQuery/SQL queries for production investigation | Finding test data, investigating errors, monitoring submission rates |
| `agent-context/how-to/` | Step-by-step task guides (run UDL locally, update workflow summary Jira tickets) | Setting up UDL for local development; updating a workflow summary ticket |
| `agent-context/personal/` | Performance checkin and career documents | Only when directly asked about past work, initiatives, or performance |
| `agent-context/workflow-platform.md` | Architecture, config format, build commands, and migrated workflows for the new Workflow Platform (future WFE replacement, not team-owned) | Working in or alongside the workflow-platform repo; understanding the future direction |

---

## Repositories

| Repo | Path | Stack | Purpose |
|---|---|---|---|
| **WFE** (Workflow Engine) | `/Users/ec825m/se-workflow-setup/workflow-engine` | PHP/Symfony | Graph traversal, runId creation, which DSE nodes to render |
| **DSE** (Dynamic Sequence Engine) | `/Users/ec825m/se-workflow-setup/dynamic-sequence-engine-gql-server` | TypeScript/Node.js | GraphQL BFF; hydrates frontend components |
| **Frontend** | `/Users/ec825m/se-workflow-setup/se-frontend-core` | TypeScript/React | Renders workflow components; publishes `@wayfair/se-workflow-ui` |
| **UDL** (Unified Data Layer) | `/Users/ec825m/service-eng-order-access-gql-federation` | Java/Spring Boot | DGS GraphQL server; order data, ticket creation, mutations |
| **Service Hub** (external team) | `/Users/ec825m/service-hub-ui` | TypeScript/Next.js | Agent-only app (Turborepo monorepo); consumes `@wayfair/se-workflow-ui` as a client — we own the workflow integration portions only |
| **Workflow Platform** (external team) | `/Users/ec825m/se-workflow-setup/workflow-platform` | Java 21/Spring Boot + Next.js | Future replacement for WFE (and eventually DSE); JSON-config-driven graph engine — not team-owned, but awareness required |

---

## Key Concepts

- **runId** — unique identifier for a workflow session (e.g. `rap-diagnosis.1.0.00.976428001769797935697cf930ad8ac4.77797010`)
- **Aerospike** — holds the in-flight session while the user traverses the workflow
- **SPDB** — PostgreSQL workflow platform database (`workflow-platform_db`); persists run metadata
- **Workflow GUID** — identifies the workflow type (e.g. `rap-diagnosis`, `returns`, `wims`)
- **Component Value Store (CVS)** — the stored map of all user input selections for a run
- **Entity** — what traverses the WFE graph (ORDER or ORDER_ITEM)
- **RAP** — Report a Problem; most complex workflow, ends with a customer resolution (refund, replacement, discount, parts)
- **WIMS** — Where Is My Stuff
- **Request Replay / Save State** — ability for an agent to pick up a customer's prior workflow run exactly where it left off
- **handoffType** — enum indicating why a workflow is being resumed: `CONTACT_US`, `CUSTOMER_NEEDS_TIME`, `AGENT_CONTINUITY`, `RECENTLY_COMPLETED`

---

## Build & Development Commands

### WFE (PHP/Symfony)

```shell
make default                    # Initial setup
make up                         # Start Docker containers
make down                       # Stop containers
make composer                   # Install dependencies
make phpunit                    # Run PHPUnit tests
make fix                        # Fix code style (ECS)
make phpstan                    # Static analysis
make validate-workflow-configs  # Validate workflow configs
make generate                   # Generate code (openapi + node schemas)
make bash                       # Open shell in container
make logs                       # Docker logs

# Run a single test
docker-compose run --user "$(id -u):$(id -g)" --entrypoint composer buildbox phpunit -- --filter=TestNameHere
```

### DSE (TypeScript/Node.js, node 14)

```shell
yarn install
yarn build
yarn start-dev                 # Hot-reload dev server
yarn test
yarn test -- -t "test name"
yarn lint
yarn check-types
yarn generate                  # Generate GraphQL types
```

### Frontend (TypeScript/React, node 18)

```shell
yarn install
yarn build
yarn watch
yarn test
yarn lint
yarn workspace @wayfair/se-workflow-ui storybook   # Storybook on port 9009
```

### UDL (Java/Spring Boot)

```shell
mvn clean install -DskipTests
mvn test
mvn test -Dtest=TestClass#testMethod
mvn checkstyle:check@compile-checkstyle

# Local run — see agent-context/how-to/run-udl-locally.md for full steps
make up-deps && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local -pl api -o -DskipTests
```

### Service Hub (TypeScript/Next.js, node 24)

```shell
# Run from monorepo root (/Users/ec825m/service-hub-ui)
yarn install
yarn workspace @wayfair/service-hub watch          # Dev server (port 8889)
yarn workspace @wayfair/service-hub test           # Jest unit tests
yarn workspace @wayfair/service-hub storybook:dev  # PRIMARY way to validate workflow changes
yarn workspace @wayfair/service-hub lint
yarn workspace @wayfair/service-hub type-check
yarn workspace @wayfair/service-hub gql:update-all
yarn workspace @wayfair/service-hub unleash:generate
```

---

## Service Hub Workflow Integration

Service Hub is an **agent-only** Next.js app that consumes `@wayfair/se-workflow-ui` (our Frontend package) as an external client. We own only the workflow integration portions.

**Validating changes:** Use Storybook (`yarn workspace @wayfair/service-hub storybook:dev`) — there is a story for the workflow components. This is the primary validation path without a full local stack.

### Key files we own

| File | Purpose |
|---|---|
| `apps/service-hub/src/components/shared/wizards/agent-workflow.tsx` | Top-level workflow component; switches between v2 (CDN remote module) and v3 (library) rendering based on `enable_se_workflow_ui_library` Unleash flag |
| `apps/service-hub/src/components/shared/wizards/workflow-platform-container.tsx` | Renders `<WorkflowUi>` from `@wayfair/se-workflow-ui` directly as a React component (v3 / library path) |
| `apps/service-hub/src/components/shared/wizards/load-agent-workflow-remote-modules.ts` | Loads workflow as CDN webpack bundle, mounts via `window.agentWorkflow.renderAgentWorkflow()` (v2 / legacy path) |
| `apps/service-hub/src/components/shared/wizards/use-workflow-state-manager.ts` | Queries `postOrderWorkflowHandoffState`; persists cleared-handoff state in `localforage`; controlled by `enable_wfp_save_state` flag |
| `apps/service-hub/src/components/shared/wizards/wizard.tsx` | Wraps `<AgentWorkflow>` in a Suspense boundary |

### Two rendering modes

- **v3 (library, `enable_se_workflow_ui_library = true`):** `<WorkflowUi>` rendered directly as a React component. Current/new path.
- **v2 (remote module, flag = `false`):** Workflow loaded as a separate CDN webpack bundle, mounted imperatively. Legacy path.

### v2 vs v3 UI layout

- **v2:** Wizard renders inline in the Order tab panel
- **v3:** Wizard renders inside `<FloatingDraggable>`, controlled by `enable_v3` flag

---

## Database Access

### Local SPDB

```
Host: localhost  Port: 5432  DB: workflow-platform_db  User: app  Password: test123
```

### Production SPDB (Cloud SQL)

```bash
# Start proxy on port 5433 (avoids conflict with local Docker SPDB on 5432)
cloud-sql-proxy --auto-iam-authn --port 5433 wf-gcp-us-workflow-plat-prod:us-east4:workflow-platform-d22a16ad &

# Connect
psql "host=127.0.0.1 port=5433 dbname=workflow-platform_db user=echapdelaine@wayfair.com sslmode=disable"

# Query directly
psql "host=127.0.0.1 port=5433 dbname=workflow-platform_db user=echapdelaine@wayfair.com sslmode=disable" -c "YOUR SQL HERE;"
```

**Always use `--port 5433`** — port 5432 conflicts with the local Docker SPDB.
Direct `gcloud sql connect` is blocked by org policy — always use the proxy.

Key table: `public.journey_flow_run_metadata`
- `initial_workflow_run_id`, `run_status`, `order_id`, `order_product_id`, `customer_id`, `employee_id`
- `component_value_stores` — JSON of all user selections
- `expression_evaluator_stores` — JSON of expression evaluator decisions

---

## Important File Locations

| What | Path |
|---|---|
| Workflow graph definitions | `workflow-engine/src/WorkflowJSON/` |
| Workflow link definitions | `workflow-engine/src/WorkflowLinks/workflow-links.json` |
| DSE node definitions (RAP example) | `dynamic-sequence-engine-gql-server/src/workflow-config/rap-diagnosis/1.0.0/index.ts` |
| Request replay logic | `dynamic-sequence-engine-gql-server/src/app/request-replay.ts` |
| Workflow summary registry | `dynamic-sequence-engine-gql-server/src/request-replay/workflow-summary/workflow-registry.ts` |
| Workflow summary helpers | `dynamic-sequence-engine-gql-server/src/request-replay/workflow-summary/helpers.ts` |
| Component name mapping (replay) | `dynamic-sequence-engine-gql-server/src/app/componentNameMapping.ts` |
| WireMock stubs | `se-workflow-setup/mocks/mappings/` |

---

## Production BigQuery Tables (Quick Reference)

Always filter by `eventDate` (partition column). `journeyFlowName` is **UPPERCASE** in Scribe tables.

| Table | Purpose |
|---|---|
| `wf-gcp-us-ae-scribe-v2-prod.scribe_postorder.tbl_journey_flow_submitted` | Submitted workflow runs |
| `wf-gcp-us-ae-scribe-v2-prod.scribe_postorder.tbl_journey_flow_intermediate_step_completed` | Intermediate steps during a run |
| `wf-gcp-us-ae-scribe-v2-prod.scribe_postorder.tbl_journey_flow_request_event_log_details` | DSE request errors |
| `wf-gcp-us-ae-sql-data-prod.elt_order.tbl_order_product_customer_attachment` | Customer photo uploads |
| `wf-gcp-us-ae-ph-analytics-prod.curated_metadata.tbl_curated_employee` | Employee metadata (filter `isCurrentFlag = 1`) |

See `agent-context/queries/helpful-bigquery-queries.sql` for ready-to-use query templates.

---

## Code Style

### WFE (PHP): PSR-12, PHP 8.1 types, dependency injection, PHPUnit tests
### DSE (TypeScript): ESLint, Prettier, 2-space indent, named exports, alphabetical imports
### Frontend (TypeScript/React): Prettier, functional components with hooks, 2-space indent
### UDL (Java): Google Java Style, 2-space indent, 120 char line limit, K&R braces, full Javadoc on public APIs, `@Value` over `@Data`, test naming `test{Method}_when{Scenario}_then{Outcome}`

---

## Development Philosophy

### Minimize unintended consequences
Workflows share a lot of logic. Before changing any function, type, helper, or constant, search for all usages across all repos and reason through the impact on each one. If a change could affect a code path you weren't asked to touch, flag it or find a narrower solution.

### Prefer the simplest solution
Make as few changes as possible to solve the problem. A small targeted fix is almost always better than a refactor. Cross-repo changes (schema changes, shared library updates, new GraphQL fields) multiply the surface area for breakage and review burden — avoid them unless the problem genuinely cannot be solved within the repo at hand.

### Ask questions during development
When working on a task incrementally, ask clarifying questions before going down a path that might be wrong. When asked to complete a feature entirely, make good decisions autonomously and summarize the key choices made after finishing.

### Comments: high-level only
Write a 1–2 line comment explaining *why* something non-obvious is happening or what a block of logic is doing at a high level. Do not over-explain — the engineers reading this code can follow TypeScript, PHP, and Java. Specifically:
- Do not comment on function signatures, parameter types, or return values when they are self-evident from the code
- Do not narrate what each line does ("// call the resolver", "// set the value")
- Do not add boilerplate JSDoc on simple private functions
- A well-named function or variable often makes a comment unnecessary — prefer that

---

## Debugging Order of Operations

When investigating a bug or production issue, follow this sequence — move to the next step only if the previous one didn't give enough information:

1. **Read the repos first.** Understand the code path. Most issues can be identified by reading the relevant logic in WFE, DSE, Frontend, or UDL before looking at any data.
2. **Scribe (BigQuery).** Query the relevant Scribe tables for event-level evidence. Scribe is fast and should be the first data source. See `agent-context/queries/helpful-bigquery-queries.sql` for ready-to-use templates.
3. **Production SPDB (Cloud SQL).** Use only if Scribe didn't have enough detail. SPDB is slow — prefer Scribe. See the Database Access section above for connection instructions.
4. **Datadog logs.** Use for low-level runtime details (errors, stack traces, request/response payloads) when the above sources don't pinpoint the issue.

At any point, use Glean to look up company-specific context (internal docs, prior incidents, team ownership, etc.).

---

## Pull Request Best Practices

- Small, focused PRs reviewable in one sitting
- All tests pass before requesting review
- Follow existing patterns and conventions
- Clear description of what and why
- Link related Jira tickets
