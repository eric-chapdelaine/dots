## Verify by running it

Local testing is cheap and encouraged, so run the real flow before opening a PR. A spec with stubs proves little by itself.

- **Run every changed path once, the way production runs it.** Start it from its real entrypoint (a job through a real worker, a cron entry, a scheduled task, the endpoint) rather than calling the unit directly, then confirm the result in the database and the logs.
- **Emulate what you can't run locally.** Use a local stand-in or a small fake HTTP server, with real data shapes. Never call a real cloud account to test without my approval.
- **Stubs return what the real call returns.** Check the library source or run the call once before writing the stub. A stub that returns the wrong type hides the bug.
- **Infra changes (CDK, Terraform, Lambda, Docker):** run the stack's tests and a synth/plan, and run the container image locally on the target architecture. Diff the actual config before claiming it "matches" something.
- **Say what you couldn't emulate** under "Not tested", and propose a check for me to approve.
