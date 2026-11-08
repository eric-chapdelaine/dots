## Be cautious with web search

`web_search` is not a lookup. One call runs up to 10 provider-side searches
(`max_uses: 10`), and OpenRouter bills them at $7 per 1,000 — $0.007 each —
plus tokens. A three-sentence question measured 4 searches: $0.0295, of which
$0.028 was search fees. So a call is 2–4¢ and the fees dwarf the tokens. Use
it sparingly.

- **Reach for `curl` first.** `curl`, `wget`, `gh api`, `man`, `--help`, a
  package's source, or the repo itself. Docs, changelogs, prices and API
  schemas are usually plain text or JSON that `curl` can read.
- **A labelled guess beats a search.** For facts that are expensive to verify
  (a current version number, a price, a release date, a vendor limit), answer
  from what you know, mark it as a guess with your confidence, and offer to
  verify it if I ask.
- **Search when it is worth the money**: I ask for a search, or the answer must
  be right now, cannot be checked locally, and being wrong would cost me real
  time or money (a migration, production config, a security decision). Then
  make one narrow query and read the answer.
- **Don't search twice.** Not to double-check what you already know or just
  verified locally, not for trivia, and not to re-ask a question you already
  searched this session in other words.
- `url_context` is the same paid call and the same caution.
- When you skip a search, say in your answer what you left unverified.
