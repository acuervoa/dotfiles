local M = {}

function M.check()
	vim.health.start("codex.nvim (local)")

	if vim.fn.executable("codex") == 1 then
		vim.health.ok("CLI 'codex' disponible en PATH")
	else
		vim.health.error("CLI 'codex' no encontrada en PATH")
	end

	if vim.fn.executable("git") == 1 then
		vim.health.ok("git disponible")
	else
		vim.health.warn("git no encontrado; :CodexDiff y :CodexExplainRepo pueden fallar")
	end
end

return M
