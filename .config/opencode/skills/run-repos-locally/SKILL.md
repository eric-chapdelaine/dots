---
name: run-repos-locally
description: Step-by-step instructions for starting each repo in the Service Workflows local dev stack (WFE, DSE, Workflow Platform, Mocks, Storybook, UDL).
---

## Overview

The full local stack for the Service Workflows team consists of several repos started in a specific order. Each repo has its own Docker network or Node/Java process. The `se-workflow-setup` monorepo at `/Users/ec825m/se-workflow-setup` is the root that ties them all together.

**Quick start (full stack from scratch):** `make default` from `se-workflow-setup`. This Vault-logins, clones repos, and brings up every service sequentially — but it is slow. Prefer the per-service instructions below when you only need a subset.

---

## Services & Ports

| Service | Path | Port | Notes |
|---|---|---|---|
| **WFE** (Workflow Engine, PHP) | `se-workflow-setup/workflow-engine` | 8380 (ingress) | Docker |
| **DSE** (Dynamic Sequence Engine, Node) | `se-workflow-setup/dynamic-sequence-engine-gql-server` | 5000 (GraphQL) | Docker or `yarn start-dev` |
| **Apollo Router** | `se-workflow-setup/dynamic-sequence-engine-gql-server` | 4000 | Docker; JWT auth validates here |
| **Workflow Platform** (WFP, Java) | `se-workflow-setup/workflow-platform` | 8080 | Docker |
| **Mocks** (WireMock) | `se-workflow-setup/mocks/` | 9200 | Root docker-compose |
| **Storybook** (Frontend) | `se-workflow-setup/se-frontend-core` | 9009 | `yarn storybook-fixed-port` |
| **UDL** (Java/Spring Boot) | `/Users/ec825m/service-eng-order-access-gql-federation` | 8080 | Local Maven run |
| **SPDB** (PostgreSQL) | WFP docker-compose | 5432 (local) | Part of WFP stack |
| **Aerospike** | Root docker-compose | 3000 | Part of WFP stack |

---

## Starting Each Service

### 1. Mocks (WireMock) — start first

Mocks must be running before WFE and DSE so they can reach downstream dependencies.

```bash
cd /Users/ec825m/se-workflow-setup
make mocks-v2
# or: docker compose up mocks
```

Runs at `http://localhost:9200`. Admin UI at `http://localhost:9200/__admin/`.

---

### 2. WFE (PHP/Symfony) — Workflow Engine

```bash
cd /Users/ec825m/se-workflow-setup/workflow-engine
make up           # starts Docker containers
# If rebuilding after code changes:
make build_and_up
```

If you've edited PHP files, rebuild before `make up`:
```bash
make composer     # installs PHP deps
make build_and_up # rebuilds Docker image and brings it up
```

Key commands:
```bash
make phpunit      # run tests
make phpstan      # static analysis
make fix          # fix code style
make validate-workflow-configs  # validate workflow JSON configs
make bash         # shell into the container
make logs         # follow Docker logs
```

---

### 3. Workflow Platform (WFP, Java/Spring Boot)

**Important:** After code changes, you must rebuild the Docker image — `docker compose restart service` reuses the old image.

```bash
cd /Users/ec825m/se-workflow-setup/workflow-platform
mvn clean install -DskipTests          # build JAR
docker compose build service           # build Docker image
docker compose up -d service           # start (also starts psql-local, redis-local, aerospike-local)
```

To just start dependencies (no rebuild):
```bash
docker compose up -d redis-local aerospike-local psql-local
docker compose up -d service
```

SPDB (PostgreSQL) is accessible at `localhost:5432` (local Docker), DB `workflow-platform_db`, user `app`, password `test123`.

---

### 4. DSE (TypeScript/Node.js)

**Node version:** 14.17.3 — use `nvm use 14.17.3` before running.

Option A — Docker (recommended for integration with WFP):
```bash
cd /Users/ec825m/se-workflow-setup/dynamic-sequence-engine-gql-server
yarn container:install
yarn local-setup          # brings up DSE + Apollo Router in Docker
```

Option B — hot-reload dev process (for active DSE development):
```bash
cd /Users/ec825m/se-workflow-setup/dynamic-sequence-engine-gql-server
nvm use 14.17.3
yarn install
yarn start-dev            # hot-reload server on port 5000
```

Key commands:
```bash
yarn test                 # Jest tests
yarn test -- -t "name"    # single test
yarn lint                 # ESLint + type check + Prettier
yarn check-types          # TypeScript only
yarn generate             # regenerate GraphQL types
```

**Auth note:** The Apollo Router on port 4000 validates JWTs using the symmetric secret `bats-5cXE3NH`. Direct DSE on port 5000 rejects symmetric JWTs — always go through the router (port 4000) for authenticated requests.

---

### 5. Storybook (Frontend, React)

**Node version:** 18 — use `nvm use 18` before running.

```bash
cd /Users/ec825m/se-workflow-setup/se-frontend-core/packages/se-workflow-ui
nvm use 18
yarn install
yarn gql:update-all       # update GraphQL types (requires DSE running at port 4000)
yarn storybook-fixed-port # start Storybook at http://localhost:9009
```

The workflow story is at: `http://localhost:9009/?path=/story/workflow--workflow`

Storybook URL params for a workflow:
```
guid:<workflow-guid>;version:<x-x-x>;orderId:<id>;customerId:<id>;authToken:<jwt>
```

**CSS issue (pre-existing):** Some workflows show `Cannot find module './index.wayfair.css'` — this is a known pre-existing issue with webpack hot-update chunks. Restart Storybook fresh if it blocks rendering.

**JWT for testing (7-day token, includes employeeId):**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjdXN0b21lcklkIjoiMTAwMDAwMDAxIiwiZW1wbG95ZWVJZCI6InRlc3QtZW1wbG95ZWUtMTIzIiwiaWF0IjoxNzc2NzE5MzIzLCJleHAiOjE3NzczMjQxMjN9.TaJTmyXL2nE4IPpgi5XD6FSHjnJtAU0zAFWbhP0HDlM
```

Secret: `bats-5cXE3NH`. Generate a new token with any JWT tool if this one expires.

---

### 6. UDL (Java/Spring Boot) — only needed for order data mutations

See `/Users/ec825m/agent-context/how-to/run-udl-locally.md` for full steps. Summary:

```bash
cd /Users/ec825m/service-eng-order-access-gql-federation
pkill -9 java                                         # kill stale processes first
find . -name "target" -maxdepth 2 -type d | xargs rm -rf
docker compose up -d aerospike-local spanner migrate-apply
docker compose run -d local-secret-distributor        # wait ~15s for secrets
./mvnw install -DskipTests -Dmaven.test.skip=true     # ~3-5 min
./mvnw spring-boot:run -Dspring-boot.run.profiles=local -pl api -o -DskipTests -Dmaven.test.skip=true
```

Service ready when you see: `Started App in XX seconds`.

---

## Recommended Startup Order

1. **Mocks** (`make mocks-v2` from `se-workflow-setup`)
2. **WFP** (`docker compose up -d service` from `workflow-platform`)
3. **DSE** (`yarn local-setup` from `dynamic-sequence-engine-gql-server`)
4. **Storybook** (`yarn storybook-fixed-port` from `se-frontend-core/packages/se-workflow-ui`)
5. **UDL** (only if needed for order data)

WFE is less commonly needed for local workflow testing — WFP replaces it in the new stack.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| WFP returns 400 on initiate | Check that all `nextNode` references in JSON configs exist; run `make validate-workflow-configs` in WFE |
| `docker compose restart service` doesn't pick up code changes | Must rebuild: `docker compose build service && docker compose up -d service` |
| `Tag.of(GUID, null)` NPE in WFP | Wrong field names in initiate request — correct fields: `guid`, `version`, `attributes: {orderId, orderProductId, customerId}` |
| DSE rejects JWT on port 5000 | Use Apollo Router on port 4000 instead |
| `select-manage-financials-action` throws `PostOrderWorkflowGeneralError` | JWT missing `employeeId` claim — regenerate token with `employeeId` |
| Storybook CSS module error | Pre-existing issue; kill Storybook process and restart fresh |
| UDL `AsyncOperationRepository` bean not found | Using wrong Spring profile — use `local`, not `test` |
| Two Maven processes corrupt MapStruct generated files | `pkill -9 java`, delete all `target/` dirs, rebuild once |
