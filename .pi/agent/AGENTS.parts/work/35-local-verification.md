## Verify by running it

Local testing is cheap and encouraged, so run the real flow before opening a PR. A spec with stubs proves little by itself.

- **Run every changed path once, the way production runs it.** A job goes through a real Sidekiq worker (`Sidekiq::Testing.disable!`, then `perform_async`), not just `perform`. A cron entry, rake task or endpoint is started from its real entrypoint. Check the result in the DB and logs.
- **Emulate what you can't run locally.** Use a local stand-in for AWS (moto or LocalStack for S3, a small fake HTTP server for Lambda) via `AWS_ENDPOINT_URL_*`. Use real data shapes, for example a release file copied read-only. Never call real AWS to test without my approval.
- **Stubs return what the real call returns.** Check the library source or run the call once before writing the stub. A stub that returns the wrong type hides the bug.
- **Infra changes (CDK, Lambda, Docker):** run the stack's jest tests and `cdk synth`, and run the container image locally on the target architecture. Diff the actual config before claiming it "matches" something.
- **Say what you couldn't emulate** (for example, the real Lambda runtime) under "Not tested", and propose a staging check for me to approve.
