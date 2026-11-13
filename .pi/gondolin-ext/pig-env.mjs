#!/usr/bin/env node
// pig-env: long-lived owner of a named Gondolin VM that several pi agents can share.
// The VM's network policy and lifetime belong to this process, not to any one agent.
//
//   pig-env up <name> --mount <host-path> [--mount ...] [--memory 4G] [--cpus 4] [--disk 20G] [--image dev-base:latest] [--from <snapshot>]
//   pig-env list
//   pig-env exec <name> [--cwd <path>] -- <cmd...>
//   pig-env snapshot <name>        # checkpoint to ~/.cache/pig-env/snapshots/<name>.qcow2, then keep running from it
//   pig-env down <name>
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { RealFSProvider, VM, VmCheckpoint } from "@earendil-works/gondolin";
import { GUEST_BOOTSTRAP, guestEnv, gitMounts, imageOptions, networkOptions, toolMounts } from "./vm-env.mjs";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const STATE_DIR = path.join(os.homedir(), ".cache", "pig-env");
const ENVS_DIR = path.join(STATE_DIR, "envs");
const SNAP_DIR = path.join(STATE_DIR, "snapshots");
const GONDOLIN = path.join(HERE, "node_modules", ".bin", "gondolin");
const NAME_RE = /^[a-z0-9][a-z0-9._-]{0,47}$/;

function die(msg) {
	console.error(`pig-env: ${msg}`);
	process.exit(1);
}

function parse(argv) {
	const opts = { mounts: [], rest: [] };
	for (let i = 0; i < argv.length; i++) {
		const a = argv[i];
		if (a === "--") {
			opts.rest = argv.slice(i + 1);
			break;
		}
		const next = () => argv[++i] ?? die(`${a} needs a value`);
		if (a === "--mount") opts.mounts.push(fs.realpathSync(path.resolve(next())));
		else if (a === "--memory") opts.memory = next();
		else if (a === "--cpus") opts.cpus = Number(next());
		else if (a === "--image") opts.image = next();
		else if (a === "--disk") opts.disk = next();
		else if (a === "--from") opts.from = next();
		else if (a === "--cwd") opts.cwd = next();
		else if (a === "--json") opts.json = true;
		else opts.rest.push(a);
	}
	return opts;
}

const envFile = (name) => path.join(ENVS_DIR, `${name}.json`);

function readEnv(name) {
	try {
		return JSON.parse(fs.readFileSync(envFile(name), "utf8"));
	} catch {
		return null;
	}
}

function alive(pid) {
	try {
		process.kill(pid, 0);
		return true;
	} catch {
		return false;
	}
}

export function liveEnv(name) {
	const env = readEnv(name);
	return env && alive(env.pid) ? env : null;
}

function snapshotPath(name) {
	return path.join(SNAP_DIR, `${name}.qcow2`);
}

async function up(name, opts) {
	if (!NAME_RE.test(name)) die(`invalid env name "${name}" (use [a-z0-9._-])`);
	if (liveEnv(name)) die(`env "${name}" is already running (pid ${readEnv(name).pid})`);
	if (opts.mounts.length === 0) die("at least one --mount <host-path> is required");
	fs.mkdirSync(ENVS_DIR, { recursive: true });

	// Identity mounts (guest path == host path) keep worktree .git pointers and absolute paths valid.
	const mountPaths = [...new Set([...opts.mounts, ...opts.mounts.flatMap(gitMounts)])];
	const mounts = { ...Object.fromEntries(mountPaths.map((p) => [p, new RealFSProvider(p)])), ...toolMounts() };
	const net = networkOptions();
	const vmOptions = {
		sessionLabel: `pig-env ${name}`,
		memory: opts.memory ?? "4G",
		cpus: opts.cpus ?? 4,
		env: { ...guestEnv(), ...net.env },
		...(net.httpHooks ? { httpHooks: net.httpHooks } : {}),
		tcp: net.tcp,
		dns: net.dns,
		vfs: { mounts },
		rootfs: { size: opts.disk ?? "20G" },
		...(await imageOptions(opts.image)),
	};

	let vm;
	if (opts.from) {
		const snap = fs.existsSync(opts.from) ? opts.from : snapshotPath(opts.from);
		if (!fs.existsSync(snap)) die(`snapshot not found: ${opts.from}`);
		vm = await VmCheckpoint.load(snap).resume(vmOptions);
	} else {
		vm = await VM.create(vmOptions);
	}
	// Also forces session IPC registration, which is lazy, so other processes can attach.
	await vm.exec(["/bin/sh", "-c", GUEST_BOOTSTRAP]);

	const record = { name, id: vm.id, pid: process.pid, mounts: mountPaths, guestEnv: vmOptions.env, memory: vmOptions.memory, cpus: vmOptions.cpus, from: opts.from ?? null, image: opts.image ?? null, startedAt: new Date().toISOString() };
	fs.writeFileSync(envFile(name), JSON.stringify(record, null, 2));
	console.log(`pig-env ${name} up: vm ${vm.id}`);
	console.log(`  mounts: ${mountPaths.join(", ")}`);
	console.log(`  attach an agent: PIG_ENV=${name} pig    |    shell: pig-env exec ${name} -- bash`);

	let stopping = false;
	const stop = async (code = 0) => {
		if (stopping) return;
		stopping = true;
		try {
			await vm.close();
		} finally {
			const cur = readEnv(name);
			if (cur?.pid === process.pid) fs.rmSync(envFile(name), { force: true });
			process.exit(code);
		}
	};
	process.on("SIGINT", () => void stop());
	process.on("SIGTERM", () => void stop());

	// Snapshot requests arrive as a file so they stay owned by this process.
	const req = path.join(ENVS_DIR, `${name}.snapshot-request`);
	setInterval(async () => {
		if (stopping || !fs.existsSync(req)) return;
		fs.rmSync(req, { force: true });
		stopping = true;
		fs.mkdirSync(SNAP_DIR, { recursive: true });
		const out = snapshotPath(name);
		fs.rmSync(out, { force: true });
		const cp = await vm.checkpoint(out);
		console.log(`snapshot written: ${cp.path}`);
		vm = await cp.resume(vmOptions);
		await vm.exec(["/bin/sh", "-c", GUEST_BOOTSTRAP]);
		fs.writeFileSync(envFile(name), JSON.stringify({ ...record, id: vm.id, snapshot: out }, null, 2));
		fs.writeFileSync(`${req}.done`, out);
		console.log(`resumed from snapshot: vm ${vm.id}`);
		stopping = false;
	}, 500).unref?.();
	await new Promise(() => {});
}

function list(opts) {
	fs.mkdirSync(ENVS_DIR, { recursive: true });
	const rows = fs.readdirSync(ENVS_DIR).filter((f) => f.endsWith(".json")).map((f) => JSON.parse(fs.readFileSync(path.join(ENVS_DIR, f), "utf8"))).filter((e) => alive(e.pid));
	const snaps = fs.existsSync(SNAP_DIR) ? fs.readdirSync(SNAP_DIR).filter((f) => f.endsWith(".qcow2")).map((f) => f.replace(/\.qcow2$/, "")) : [];
	if (opts.json) return console.log(JSON.stringify({ envs: rows, snapshots: snaps }, null, 2));
	if (!rows.length) console.log("no running envs");
	for (const e of rows) console.log(`${e.name}\tvm ${e.id.slice(0, 8)}\tpid ${e.pid}\t${e.memory}/${e.cpus}cpu\t${e.mounts.join(",")}${e.from ? `\tfrom ${e.from}` : ""}`);
	if (snaps.length) console.log(`snapshots: ${snaps.join(", ")}`);
}

function exec(name, opts) {
	const env = liveEnv(name) ?? die(`env "${name}" is not running`);
	const cmd = opts.rest.length ? opts.rest : ["bash"];
	const envArgs = Object.entries(env.guestEnv ?? {}).flatMap(([k, v]) => ["--env", `${k}=${v}`]);
	const args = ["exec", "--sock", env.id, "--cwd", opts.cwd ?? env.mounts[0], ...envArgs, "--", "/bin/sh", "-c", 'exec "$@"', "sh", ...cmd];
	const r = spawnSync(GONDOLIN, args, { stdio: "inherit" });
	process.exit(r.status ?? 1);
}

async function snapshot(name) {
	liveEnv(name) ?? die(`env "${name}" is not running`);
	const req = path.join(ENVS_DIR, `${name}.snapshot-request`);
	fs.rmSync(`${req}.done`, { force: true });
	fs.writeFileSync(req, "");
	for (let i = 0; i < 600; i++) {
		if (fs.existsSync(`${req}.done`)) {
			console.log(fs.readFileSync(`${req}.done`, "utf8"));
			fs.rmSync(`${req}.done`, { force: true });
			return;
		}
		await new Promise((r) => setTimeout(r, 500));
	}
	die("snapshot timed out after 5 minutes");
}

function down(name) {
	const env = liveEnv(name) ?? die(`env "${name}" is not running`);
	process.kill(env.pid, "SIGTERM");
	console.log(`stopping ${name} (pid ${env.pid})`);
}

const [cmd, name, ...rest] = process.argv.slice(2);
const opts = parse(rest);
if (cmd === "up") await up(name ?? die("up <name>"), opts);
else if (cmd === "list") list(parse([name, ...rest].filter(Boolean)));
else if (cmd === "exec") exec(name ?? die("exec <name>"), opts);
else if (cmd === "snapshot") await snapshot(name ?? die("snapshot <name>"));
else if (cmd === "down") down(name ?? die("down <name>"));
else {
	console.log(fs.readFileSync(fileURLToPath(import.meta.url), "utf8").split("\n").slice(1, 10).join("\n").replace(/^\/\/ ?/gm, ""));
	process.exit(cmd ? 1 : 0);
}
