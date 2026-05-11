---
name: run-repos-locally
description: Step-by-step instructions for starting each service in a local dev stack — covers startup order, per-service commands, ports, and common troubleshooting.
---

## Overview

This skill is a template for documenting local dev stack startup instructions. Fill in the specifics for the project at hand.

The general pattern for a multi-service local stack:

1. Start any mock/stub servers first (so other services can reach dependencies on startup)
2. Start databases and infrastructure services
3. Start backend services in dependency order
4. Start frontend dev servers last

---

## Template: Services & Ports

| Service | Path | Port | Notes |
|---|---|---|---|
| **Mocks** | `/path/to/mocks` | 9200 | Start first |
| **Database** | (docker) | 5432 | Part of backend stack |
| **Backend API** | `/path/to/api` | 8080 | Docker or local process |
| **Frontend** | `/path/to/frontend` | 3000 | Hot-reload dev server |

---

## Template: Starting Each Service

### 1. Mocks / Stubs — start first

```bash
docker compose up -d mocks
```

### 2. Database

```bash
docker compose up -d db
```

### 3. Backend

```bash
# Build
./mvnw clean install -DskipTests   # Java
# or
yarn build                          # Node

# Run
./mvnw spring-boot:run              # Java
# or
yarn start-dev                      # Node
```

### 4. Frontend

```bash
yarn install
yarn dev        # or: yarn storybook
```

---

## Common Troubleshooting

| Problem | Fix |
|---|---|
| Service fails to start, can't reach dependency | Check that mocks/stubs are running first |
| Code changes not picked up in Docker | Rebuild image: `docker compose build && docker compose up -d` |
| Port already in use | `lsof -i :<port>` to find and kill the process |
| DB migrations not applied | Run migration command before starting service |
| Hot-reload not working | Kill process and restart fresh |
