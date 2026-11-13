// Shared guest setup for pig (private VM) and pig-env (shared VM).
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { createHttpHooks, ensureImageSelector, ReadonlyProvider, RealFSProvider } from "@earendil-works/gondolin";
import { fileURLToPath } from "node:url";

// Machine-local guest scripts (guest-bin/, untracked, optional), mounted read-only so every VM and snapshot fork runs the
// current version.
const GUEST_BIN = "/opt/pig-bin";
const HOST_GUEST_BIN = path.join(path.dirname(fileURLToPath(import.meta.url)), "guest-bin");
export function toolMounts() {
	if (!fs.existsSync(HOST_GUEST_BIN)) return {};
	return { [GUEST_BIN]: new ReadonlyProvider(new RealFSProvider(HOST_GUEST_BIN)) };
}

// Guest HOME lives on the root disk (not tmpfs) so gem/npm caches survive snapshots.
const GUEST_HOME = "/home/agent";
const GUEST_PATH = `/opt/pig-bin:/usr/libexec/postgresql18:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:${GUEST_HOME}/.local/bin`;

export function guestEnv() {
	// The host's Postgres is reached as host-postgres. Redis is the VM's own (started in GUEST_BOOTSTRAP), so a VM's job
	// workers never pick up queues that other checkouts left in the host Redis.
	return { HOME: GUEST_HOME, PATH: GUEST_PATH, LANG: "C.UTF-8", TERM: "xterm-256color", PGHOST: "host-postgres", PGPORT: "5432", REDIS_URL: "redis://127.0.0.1:6379/0" };
}

// First command in a fresh VM: make HOME exist (the image can't create it without a Docker build).
export const GUEST_BOOTSTRAP = `mkdir -p ${GUEST_HOME} && git config --global --add safe.directory '*' 2>/dev/null; command -v redis-server >/dev/null && ! redis-cli ping >/dev/null 2>&1 && redis-server --daemonize yes --save '' --appendonly no --logfile /var/log/redis.log >/dev/null; true`;

// The real GitHub token stays on the host; the guest gets a placeholder that is only swapped in for GitHub hosts.
// No allowedHosts: the guest has normal internet access.
export function networkOptions() {
	const r = spawnSync("gh", ["auth", "token"], { encoding: "utf8" });
	const token = r.status === 0 ? r.stdout.trim() : "";
	const tcp = { hosts: { "host-postgres:5432": "127.0.0.1:5432", "host-redis:6379": "127.0.0.1:6379" } };
	const dns = { mode: "synthetic", syntheticHostMapping: "per-host" };
	if (!token) return { env: {}, tcp, dns };
	const { httpHooks, env } = createHttpHooks({
		secrets: { GH_TOKEN: { hosts: ["api.github.com", "github.com", "*.github.com", "*.githubusercontent.com"], value: token } },
	});
	return { httpHooks, env, tcp, dns };
}

export async function imageOptions(selector) {
	if (!selector) return {};
	const resolved = await ensureImageSelector(selector);
	return { sandbox: { imagePath: resolved.assetDir } };
}

// A git worktree's .git file points at the main repo's .git; mount that too so git works in the guest.
export function gitMounts(dir) {
	const dotGit = path.join(dir, ".git");
	try {
		if (!fs.statSync(dotGit).isFile()) return [];
		const gitdir = fs.readFileSync(dotGit, "utf8").match(/^gitdir:\s*(.+)$/m)?.[1]?.trim();
		if (!gitdir) return [];
		const common = path.resolve(dir, gitdir, "..", "..");
		return fs.existsSync(common) ? [common] : [];
	} catch {
		return [];
	}
}
