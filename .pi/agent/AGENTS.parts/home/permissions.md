## Home environment

- **Cloud is GCP.** `gcloud` reads are fine; any mutation needs my approval for that exact command. No deploys.
- **No production data.** Personal projects run locally (docker compose, SQLite, local Postgres). There is no company or customer data on this machine.
- **Projects live in `~/projects/<name>`.** Each repo has its own `AGENTS.md`; read it before changing code.
- **Secrets** are in `~/.config/secrets.sh` (untracked). Never print, commit or send them.
