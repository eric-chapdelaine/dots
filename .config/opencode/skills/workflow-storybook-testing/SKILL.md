---
name: workflow-storybook-testing
description: End-to-end UI testing via Storybook — covers fast page navigation with Playwright, WireMock stub management, and common testing patterns for component stories.
---

## Overview

Storybook is often the fastest way to run a UI component or flow end-to-end without standing up a full application stack. This skill covers:

- Navigating and interacting with Storybook stories using Playwright
- Managing WireMock stubs for mocking API responses
- Common patterns for forms, dropdowns, and async UI

---

## Navigating Storybook with Playwright

Use the `iframe.html` URL directly to bypass the Storybook chrome — faster and cleaner for programmatic interaction.

```
http://localhost:<port>/iframe.html?id=<story-id>&viewMode=story
```

### General navigation pattern

```js
async (page) => {
  await page.goto('http://localhost:9009/iframe.html?id=my-component--default&viewMode=story');
  await page.waitForTimeout(2000); // wait for initial render

  // Read current state
  const body = await page.locator('body').evaluate(el => el.innerText.substring(0, 500));
  return { body };
}
```

### Clicking buttons

```js
await page.getByRole('button', { name: 'Continue' }).click();
await page.waitForTimeout(1000); // wait for next state to load
```

### Combobox / select fields

Many dropdowns require a keypress to trigger async option loading:

```js
await page.getByRole('combobox', { name: 'Field Label' }).click();
await page.keyboard.type('a'); // triggers option list
await page.getByRole('option', { name: 'Option Name' }).click();
```

### Watching console logs

Register the listener before the action you want to capture:

```js
const logs = [];
page.on('console', msg => logs.push(`[${msg.type()}] ${msg.text()}`));
// ... interact with the page ...
return { logs };
```

### Forms with multiple required fields

Some forms only enable submit when **all** required fields have values. Fill every required field before expecting the submit button to enable.

---

## WireMock Stubs

WireMock provides a local HTTP mock server. Admin UI at `http://localhost:9200/__admin/`.

WireMock hot-reloads stubs from disk — no restart needed when you add or edit a JSON file (allow ~5s, or `POST /__admin/mappings/reset` to force it).

### Anatomy of a stub

```json
{
  "id": "unique-uuid-here",
  "name": "my_stub_name",
  "priority": 1,
  "request": {
    "url": "/api/endpoint",
    "method": "POST",
    "bodyPatterns": [
      {
        "matchesJsonPath": {
          "expression": "$.operationName",
          "equalTo": "MyOperationName"
        }
      }
    ]
  },
  "response": {
    "status": 200,
    "headers": { "Content-Type": "application/json" },
    "jsonBody": {
      "data": {
        "myField": "value"
      }
    }
  }
}
```

Key points:
- **`priority: 1`** — use for overrides; fallback/proxy stubs should be higher numbers (e.g. 10)
- **`matchesJsonPath`** — safer than `equalToJson` when the body varies by variable values
- **`jsonBody`** — use instead of `"body"` (string) to avoid JSON escaping
- The stub filename doesn't matter; the `id` field must be unique

### Checking requests and reloading

```bash
# All recent requests
curl http://localhost:9200/__admin/requests | jq '.requests[-5:] | .[].request | {url, bodyAsString}'

# Force reload stubs from disk
curl -X POST http://localhost:9200/__admin/mappings/reset
```

---

## Common Pitfalls

| Problem | Cause | Fix |
|---|---|---|
| Story renders blank | Import error or missing CSS module | Restart Storybook fresh |
| Combobox shows no options after click | Async load needs a keypress trigger | Type any letter after clicking |
| Stub not matching | Body pattern too strict | Use `matchesJsonPath` on a stable field; check `/__admin/requests` for the real body |
| New stub not picked up | WireMock hasn't reloaded | Wait 5s or `POST /__admin/mappings/reset` |
| Button not clickable | Required fields not all filled | Fill every required field first |
