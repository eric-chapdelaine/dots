return {
	{
		"aug6th/cursoragent.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("cursoragent").setup({
				terminal_cmd = vim.fn.expand("~/.local/bin/cursor-agent"),
				auto_start = true,
				track_selection = true,
				terminal = {
					split_side = "right",
					split_width_percentage = 0.4,
					provider = "native",
					git_repo_cwd = true,
				},
			})

			-- Reload buffers when Cursor Agent edits files on disk
			vim.o.autoread = true

			-- ── Agent status: tmux window glyphs + macOS notifications ──────────
			-- cursor-agent runs in IDE-integration mode and never loads hooks.json,
			-- so we drive status updates from Neovim's terminal lifecycle events.

			local function tmux_win_name(pane)
				local name = vim.trim(vim.fn.system({ "tmux", "display-message", "-t", pane, "-p", "#{window_name}" }))
				return vim.trim(name:gsub("[🤖⚠️✅%s]+$", ""))
			end

			local function tmux_rename(glyph)
				local pane = os.getenv("TMUX_PANE")
				if not pane or pane == "" then
					return
				end
				local name = tmux_win_name(pane)
				local label = glyph ~= "" and (" " .. glyph) or ""
				vim.fn.jobstart({ "tmux", "rename-window", "-t", pane, name .. label })
			end

			local function notify(msg, sound)
				local pane = os.getenv("TMUX_PANE")
				local win = (pane and pane ~= "") and tmux_win_name(pane) or ""
				local repo = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
				local branch = vim.trim(vim.fn.system({ "git", "branch", "--show-current" }))
				-- Build subtitle: "repo (branch)" or just "repo" if not a git repo
				local subtitle = (branch ~= "" and not branch:find("^fatal")) and (repo .. " (" .. branch .. ")") or repo
				local script = string.format(
					'display notification %q with title %q subtitle %q sound name %q',
					msg, win ~= "" and win or "Cursor Agent", subtitle, sound
				)
				vim.fn.jobstart({ "osascript", "-e", script })
			end

			local augroup = vim.api.nvim_create_augroup("CursorAgentStatus", { clear = true })

			-- Per-buffer session state, shared between TermOpen and TermClose callbacks.
			-- active=false prevents the deferred watch_resume timer from overriding ✅.
			local sessions = {}

			-- Agent session started: rename window and watch buffer for input-needed text.
			-- OSC 777 sequences are rendered as literal text by libvterm, so we scan lines
			-- directly rather than using TermRequest.
			vim.api.nvim_create_autocmd("TermOpen", {
				group = augroup,
				pattern = "*cursor*agent*",
				callback = function(args)
					local buf = args.buf
					local s = { active = true, waiting = false, watch_resume = false }
					sessions[buf] = s
					tmux_rename("🤖")
					vim.api.nvim_buf_attach(buf, false, {
						on_lines = function(_, _, _, first_line, last_line)
							if not s.active then
								return
							end
							local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, first_line, last_line, false)
							if not ok then
								return
							end
							for _, line in ipairs(lines) do
								if line:find("notify;Cursor", 1, true) then
									if not s.waiting then
										s.waiting = true
										s.watch_resume = false
										local agent_msg = line:match("notify;[^;]+;(.-)%s*$") or "needs your input"
										tmux_rename("⚠️")
										notify(agent_msg, "Ping")
										-- Delay before watching for resume so this batch doesn't self-reset.
										-- Guard on s.active so a closed session's timer does nothing.
										vim.defer_fn(function()
											if s.active then
												s.watch_resume = true
											end
										end, 300)
									end
									return
								elseif s.watch_resume and line:match("%S") then
									s.waiting = false
									s.watch_resume = false
									tmux_rename("🤖")
									return
								end
							end
						end,
					})
				end,
			})

			-- Reset to 🤖 when user focuses the terminal to answer (agent resumed)
			vim.api.nvim_create_autocmd("TermEnter", {
				group = augroup,
				pattern = "*cursor*agent*",
				callback = function()
					tmux_rename("🤖")
				end,
			})

			-- Agent session ended (done or interrupted)
			vim.api.nvim_create_autocmd("TermClose", {
				group = augroup,
				pattern = "*cursor*agent*",
				callback = function(args)
					local s = sessions[args.buf]
					if s then
						-- Deactivate before renaming so any in-flight defer_fn timer
						-- callbacks that fire afterwards don't override the ✅.
						s.active = false
						sessions[args.buf] = nil
					end
					tmux_rename("✅")
					notify("done", "Glass")
				end,
			})

			local function cursor_agent_cmd(command, set_running)
				return function()
					if set_running then
						tmux_rename("🤖")
					end
					vim.cmd(command)
				end
			end

			vim.keymap.set("n", "<leader>ca", cursor_agent_cmd("CursorAgent", true), {
				desc = "[C]ursor Agent: toggle",
			})
			vim.keymap.set("n", "<leader>cq", cursor_agent_cmd("CursorAgentAsk", true), {
				desc = "[C]ursor Agent: [Q]uestion (ask mode)",
			})
			vim.keymap.set("n", "<leader>cp", cursor_agent_cmd("CursorAgentPlan", true), {
				desc = "[C]ursor Agent: [P]lan mode",
			})
			vim.keymap.set("n", "<leader>cr", cursor_agent_cmd("CursorAgentResume", true), {
				desc = "[C]ursor Agent: [R]esume session",
			})
			vim.keymap.set("v", "<leader>cs", cursor_agent_cmd("CursorAgentSelection", true), {
				desc = "[C]ursor Agent: send [S]election",
			})
			vim.keymap.set("n", "<leader>cb", cursor_agent_cmd("CursorAgentBuffer", true), {
				desc = "[C]ursor Agent: send [B]uffer",
			})
		end,
	},
}
