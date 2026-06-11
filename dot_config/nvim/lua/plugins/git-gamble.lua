-- lua/plugins/git-gamble.lua
-- git-gamble integration (TCRDD: test && commit || revert)
-- -g / --pass  → bet that tests pass (green)
-- -r / --fail  → bet that tests fail (red)
--
-- Bindings: <leader>gG → git-gamble -g (bet green)
--          <leader>gR → git-gamble -r (bet red)
--
-- The test command is required by git-gamble.
-- Set GAMBLE_TEST_COMMAND in your shell, or configure
-- `vim.g.gamble_test_command` in your Neovim config.

return {
	{
		"git-gamble",
		dir = vim.fn.stdpath("config"),
		name = "git-gamble",
		lazy = true,
		keys = {
			{ "<leader>gG", desc = "git-gamble -g (bet green)" },
			{ "<leader>gR", desc = "git-gamble -r (bet red)" },
		},
		config = function()
			if vim.fn.executable("git-gamble") == 0 then
				vim.notify(
					"git-gamble: binary not found in PATH.\n" .. "Install it with: `cargo install git-gamble`",
					vim.log.levels.ERROR,
					{ title = "git-gamble" }
				)
				return
			end

			---Resolves the test command to pass to git-gamble.
			---Priority: GAMBLE_TEST_COMMAND env var > vim.g.gamble_test_command
			---@return string|nil
			local function resolve_test_command()
				local cmd = os.getenv("GAMBLE_TEST_COMMAND") or vim.g.gamble_test_command
				if not cmd or cmd == "" then
					vim.notify(
						"git-gamble: no test command defined.\n"
							.. "Set GAMBLE_TEST_COMMAND in your shell\n"
							.. "or add `vim.g.gamble_test_command = '...'` to your config.",
						vim.log.levels.WARN,
						{ title = "git-gamble" }
					)
					return nil
				end
				return cmd
			end

			---Runs `git-gamble <flag> -- <test_command>` and notifies of the result.
			-- Bet outcome is detected by looking for "Reverted!"
			-- in the output: git-gamble does not propagate a reliable exit code.
			---@param flag string  "-g" or "-r"
			local function run(flag)
				local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 or not git_root then
					vim.notify(
						"git-gamble: current directory is not inside a git repository.",
						vim.log.levels.WARN,
						{ title = "git-gamble" }
					)
					return
				end

				local test_cmd = resolve_test_command()
				if not test_cmd then
					return
				end

				local label = flag == "-g" and "green (--pass)" or "red (--fail)"
				local output_lines = {}

				vim.fn.jobstart({ "sh", "-c", "git-gamble " .. flag .. " -- " .. test_cmd }, {
					cwd = git_root,
					stdout_buffered = true,
					stderr_buffered = true,

					on_stdout = function(_, data)
						for _, line in ipairs(data) do
							if line ~= "" then
								table.insert(output_lines, line)
							end
						end
					end,

					on_stderr = function(_, data)
						for _, line in ipairs(data) do
							if line ~= "" then
								table.insert(output_lines, line)
							end
						end
					end,

					on_exit = function()
						local full_output = table.concat(output_lines, "\n")
						local reverted = full_output:find("Reverted!") ~= nil

						if reverted then
							vim.notify(
								("git-gamble %s: bet lost, reverted ❌"):format(label),
								vim.log.levels.WARN,
								{ title = "git-gamble" }
							)
						else
							vim.notify(
								("git-gamble %s: bet won, committed ✅"):format(label),
								vim.log.levels.INFO,
								{ title = "git-gamble" }
							)
						end

						-- A revert may have occurred: reload buffers to reflect disk state.
						vim.schedule(function()
							vim.cmd("checktime")
						end)
					end,
				})
			end

			vim.keymap.set("n", "<leader>gG", function()
				run("-g")
			end, { desc = "git-gamble -g (bet green)", silent = true })

			vim.keymap.set("n", "<leader>gR", function()
				run("-r")
			end, { desc = "git-gamble -r (bet red)", silent = true })
		end,
	},
}
