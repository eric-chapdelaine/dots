---
name: workflow-storybook-testing
description: End-to-end workflow testing via se-workflow-ui Storybook — covers theme setup (agent vs. self-service), fast page navigation with Playwright, and adding WireMock override stubs.
---

## Overview

`se-workflow-ui` Storybook (port 9009) is the primary way to run a full workflow end-to-end locally without needing service-hub. The workflow story renders `WorkflowPlatformContainer` directly, wired to the real DSE (port 4000) and real WireMock mocks (port 9200).

Story URL: `http://localhost:9009/?path=/story/workflow--workflow`

Required services (start in this order):
1. Mocks — `make mocks-v2` from `se-workflow-setup`
2. WFP — `docker compose up -d service` from `workflow-platform`
3. DSE — `yarn local-setup` from `dynamic-sequence-engine-gql-server`
4. Storybook — `yarn storybook-fixed-port` from `se-frontend-core/packages/se-workflow-ui` (Node 18)

---

## Theme: Agent vs. Self-Service

**This is the most important configuration choice.** The Storybook toolbar has a theme selector. The theme controls `isStorefront`, which gates agent-only resolutions and UI elements.

| Theme | `isStorefront` | Use when |
|---|---|---|
| `internaltools` | `false` | Testing agent flows (RAP resolutions, wrap call, employee-only options) |
| `wayfair` / `allmodern` / etc. | `true` | Testing customer self-service flows |

How it works (in `withApplicationProvider.tsx`):
```ts
const isPartner = theme === 'partnerhome';
const isStorefront = theme !== 'internaltools' && !isPartner;
```

And in `withThemeProvider.js`, `internaltools` has no dedicated CSS file — it falls back to the `wayfair` CSS but applies the `internaltools` token set:
```js
const cssTheme = theme === 'internaltools' ? 'wayfair' : theme;
```

**Rule:** Use `internaltools` theme + an employee JWT (with `wf_emid` claim) for any agent-mode test. Using a customer-facing theme with an employee JWT will still render `isStorefront = true`, which hides agent resolutions.

### Generating JWTs

The Apollo Router on port 4000 accepts RS256 JWTs signed with a test RSA key. The pre-baked employee JWT in `Workflow.args` expires 2026-05-05. To regenerate:

```bash
# Use jwt.io or any JWT tool with the RSA key from the mocks config
# Claims needed for agent mode:
{ "wf_emid": "1034042" }
```

For symmetric HS256 JWTs (DSE direct on port 5000 only — not the router), secret is `bats-5cXE3NH`.

---

## Default Story Args

`Workflow.args` in `workflow-container.stories.tsx` has hardcoded defaults for the RAP flow:

```ts
Workflow.args = {
  guid: 'rap-diagnosis',
  version: '1-0-0',
  orderId: '4276627921',
  customerId: 5678978191,
  authToken: '<employee RS256 JWT with wf_emid: 1034042>',
};
```

These can be overridden via the Storybook Controls panel or URL params:
```
?path=/story/workflow--workflow&args=guid:rap-diagnosis;version:1-0-0;orderId:4276627921;customerId:5678978191
```

---

## Navigating the Workflow with Playwright

Use the Playwright browser tools to drive the workflow programmatically. This is much faster than manual clicking.

### General navigation pattern

```js
async (page) => {
  await page.goto('http://localhost:9009/iframe.html?id=workflow--workflow&viewMode=story');
  await page.waitForTimeout(3000); // wait for initial render
  
  // Read current screen
  const body = await page.locator('body').evaluate(el => el.innerText.substring(0, 500));
  return { body };
}
```

Use `iframe.html?id=workflow--workflow` (not `/?path=...`) to get the story without the Storybook chrome — faster and cleaner for Playwright interaction.

### Clicking continue/next buttons

```js
await page.getByRole('button', { name: 'Continue' }).click();
await page.waitForTimeout(1500); // wait for next node to load
```

### Combobox/select fields

Most dropdowns require typing a character to load options:

```js
// Open combobox and type to trigger options
await page.getByRole('combobox', { name: 'Problem Type' }).click();
await page.keyboard.type('d'); // triggers option list
await page.getByRole('option', { name: 'Damaged' }).click();
```

Some comboboxes (e.g., damage location) open with Downshift and render immediately with item IDs:
```js
// Click to open, then select by item index
await page.getByRole('combobox', { name: 'Damage Location' }).click();
await page.getByRole('option', { name: /exterior/i }).click();
```

### Forms with multiple required fields

Forms like `IssueElaboration` only fire `onChange` when **all** required fields are non-null. Fill every field before expecting the Continue button to enable. Check the DSE node config to know which fields are required.

### Watching console logs

```js
const logs = [];
page.on('console', msg => logs.push(`[${msg.type()}] ${msg.text()}`));
// ... interact with the page ...
return { logs };
```

Note: `page.on('console', ...)` must be registered before the action — not after. If you need logs from a click, attach the listener first then click.

---

## WireMock Stubs

WireMock runs at `http://localhost:9200`. Admin UI: `http://localhost:9200/__admin/`.

Stub files live in `se-workflow-setup/mocks/mappings/`. WireMock hot-reloads stubs from disk — **no restart needed** when you add or edit a JSON file (the reload may take ~5s; you can also hit `POST http://localhost:9200/__admin/mappings/reset` to force it).

### Stub directory layout

```
mocks/mappings/
  rap-diagnosis1.0.0/           # workflow-scoped stubs (loaded by default)
    4276627921/                 # order-scoped override stubs
      udl_v1_nonfederated_subgraph-submit-all-set-override.json
      udl_v1_nonfederated_subgraph-rap-diagnosis-nested-item-select-eligible-override.json
  proxy/                        # fallback proxy stubs (priority 10)
```

### S2S routing (critical to understand)

There are two separate S2S paths in the local stack:

| Caller | Route | WireMock path |
|---|---|---|
| WFP | `http://mocks:8080/graphql` | `/graphql` |
| WFE (Sailor/Guzzle) | `http://mocks:8080/federation/chaos/service-to-service/introspect` | `/federation/chaos/service-to-service/...` |
| WFE → UDL mutations | `mocks:8080/udl/v1/nonfederated/subgraph` | `/udl/v1/nonfederated/subgraph` |

**Fallback proxy stubs** (priority 10 in `proxy/`) forward unmatched calls to production. If a mutation reaches production, it will fail with "Only supports query operations" because the persisted query hash is not registered in production. Always add a priority-1 override stub for any mutation you need to exercise locally.

### Anatomy of an override stub

```json
{
  "id": "c3d4e5f6-a7b8-9012-cdef-123456789003",
  "name": "udl_submit_all_set_override",
  "priority": 1,
  "request": {
    "url": "/udl/v1/nonfederated/subgraph",
    "method": "POST",
    "bodyPatterns": [
      {
        "matchesJsonPath": {
          "expression": "$.operationName",
          "equalTo": "SubmitAllSet__udl__0"
        }
      }
    ]
  },
  "response": {
    "status": 200,
    "headers": { "Content-Type": "application/json" },
    "jsonBody": {
      "data": {
        "requestAllSetResolution": {
          "__typename": "AllSetResolutionResponse",
          "isSuccess": true,
          "orderProductId": "10681251741"
        }
      }
    }
  }
}
```

Key points:
- **`priority: 1`** — always use this for overrides; the fallback proxy stubs are priority 10
- **`matchesJsonPath` on `$.operationName`** — safer than `equalToJson` because the mutation body varies by variable values
- **`matchesJsonPath` regex** — use for prefix matching: `"$.operationName[?(@=~ /RapDiagnosisNestedItemSelect.*/)]"`
- **`jsonBody`** — use this instead of `"body"` (string) to avoid JSON escaping headaches
- The stub file name doesn't matter to WireMock; the `id` field must be unique across all stubs

### Finding the operation name

Operation names come from the frontend's persisted query manifests. The format is typically `<OperationName>__udl__0` or `<OperationName>__dse__0`. To find the exact name for a mutation:

1. Open Storybook, trigger the step that fires the mutation
2. Check the WireMock request log: `GET http://localhost:9200/__admin/requests`
3. The `operationName` field in the request body is what you match against

### Checking what WireMock received

```bash
# All recent requests
curl http://localhost:9200/__admin/requests | jq '.requests[-5:] | .[].request | {url, bodyAsString}'

# Force reload stubs from disk
curl -X POST http://localhost:9200/__admin/mappings/reset
```

### Making an item eligible / choosing a resolution path

Two common override stubs needed for RAP:

**1. Make item eligible for resolutions** (`RapDiagnosisNestedItemSelect`):
- Override the eligibility query to return the item in `eligibleItems` with `canReplaceWithAdditionalRules.isEligible: true`
- See `udl_v1_nonfederated_subgraph-rap-diagnosis-nested-item-select-eligible-override.json` as a template

**2. Override the resolution response** (e.g., all-set, refund, replacement):
- Match on `$.operationName` equalTo the specific mutation name
- Return `isSuccess: true` with a valid `orderProductId`

---

## Common Pitfalls

| Problem | Cause | Fix |
|---|---|---|
| Agent resolutions not shown (no refund/replacement options) | Wrong theme — `isStorefront = true` | Switch Storybook toolbar to `internaltools` theme |
| JWT rejected by Apollo Router (port 4000) | Using HS256 JWT against RS256-only router | Generate RS256 JWT; or hit DSE directly on port 5000 (no auth for read ops) |
| Mutation fails with "Only supports query operations" | Unmatched stub falling through to production proxy | Add priority-1 WireMock stub matching the `operationName` |
| Combobox shows no options after click | Downshift needs a keypress to load async options | Type any letter after clicking to trigger the option list |
| Storybook renders blank / CSS missing | `index.wayfair.css` webpack hot-update error | Restart Storybook (`yarn storybook-fixed-port`) fresh |
| `isStorefront` is true even with employee JWT | JWT has `employeeId` but theme is not `internaltools` | Theme controls `isStorefront`, not the JWT |
| WireMock stub not matching | Body pattern too strict / wrong path | Use `matchesJsonPath` on `$.operationName` only; check `/__admin/requests` for the real body |
| New stub not picked up | WireMock hasn't reloaded | Wait 5s or `POST /__admin/mappings/reset` |
