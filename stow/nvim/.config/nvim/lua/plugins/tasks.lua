-- lua/plugins/tasks.lua
-- Overseer: keys y opts base (config y templates viven en task_runner.lua)
return {
	"stevearc/overseer.nvim",
	cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild", "OverseerTaskAction" },
	keys = {
		{ "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer: toggle task list" },
		{ "<leader>or", "<cmd>OverseerRun<cr>",    desc = "Overseer: run task" },
		{ "<leader>ob", "<cmd>OverseerBuild<cr>",  desc = "Overseer: build task" },
	},
	opts = {
		strategy = "terminal",
		task_list = {
			direction = "bottom",
			min_height = 10,
			max_height = 20,
		},
	},
}
