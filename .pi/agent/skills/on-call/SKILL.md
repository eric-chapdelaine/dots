---
name: on-call
description: Investigate an on-call request, page, alert or reported customer issue at Nile, find and prove the root cause, size the impact, and propose short-term and long-term fixes. Use for Zendesk on-call tickets, Datadog/PagerDuty alerts, alarm-bot threads, and "investigate this" reports.
---

# On-call

## 1. Gather context

- Read the whole report: the ticket (Zendesk data is readable via Metabase), the Roam thread (Roam MCP), and any AI-agent diagnosis. Treat another agent's diagnosis as a lead, not a fact.
- Check the runbook through the Notion MCP: "Eng On-Call Runbook" (page `8a7c207a64f04010a35ce2c1ca678f7e`). If a procedure matches, follow it.
- Search the LLM wiki for related issues and concepts.

## 2. Find the root cause

1. Read the code path first.
2. Then look for evidence: Datadog logs, APM and RUM (Datadog MCP), and production data via the Metabase MCP (MBQL).
3. Confirm with this specific customer's records that the cause explains the exact symptom, end to end.
4. If something only the production console can show is needed, write a read-only script to `~/scratch/<topic>/`.

Name the change that introduced it (PR or commit) when you can. Say how confident you are and what proves it.

## 3. Size the impact

How many customers or orders are affected, since when, and whether anyone is blocked right now (can't get medication, paid without a fill, and so on). Give me a SQL query or Datadog query that derives the list, not a hardcoded one, when the list matters.

## 4. Report, using the `communicate` skill

```
<1–2 sentence description of the problem and customer impact>

<short paragraph: root cause, in plain language, with confidence>

Impact: <who and how many, blocked now or not>

Short term fix: <what unblocks the affected customers now: a console command in ~/scratch, an Ops action, or comms>
Long term fix: <what stops it from recurring: a PR, monitor, or alert>

Reply for the ticket: <suggested message for me to send>
```

Also say who to ping if the fix sits in someone else's area (use `git log` / blame).

## 5. Follow through

- Apply nothing in production yourself. Give me the commands, and verify the result afterwards through Metabase.
- Record the issue and next steps in the LLM wiki.
