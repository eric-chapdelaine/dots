## Data access

- **Production data:** the Metabase MCP, using **MBQL only** (no SQL through the MCP). Prefer it over Snowflake, which lags. Use it freely for root causes, code-flow checks, estimates and single values. We have a BAA with Anthropic, OpenAI and Datadog, so working with PHI is fine. Don't mask it.
- **When the numbers matter:** write a SQL query for me to run in the Metabase UI. Use the MCP to shape it, and make it easy to read (CTEs, clear names, a one-line comment per step).
- **Production Rails console:** when code, MCPs and data aren't enough, give me a script to run, saved to `~/scratch/<topic>/`.
  - Read-only by default. Make it provably side-effect free: no saves, enqueues, callbacks, external API writes or `update_columns`.
  - Small, low-risk mutations (for example, unblocking one patient) can be console scripts if I ask. Be defensive: guard the expected state, print before and after.
  - Larger or higher-risk mutations go in a small PR with a rake task. Follow the prior art in `lib/tasks/one_time/` and `lib/tasks/backfill/`: dry run by default, `DRY_RUN=false EXPECTED_TOTAL=<n>` to apply, `TENANT=<slug>`, idempotent, and print the touched IDs for rollback.
