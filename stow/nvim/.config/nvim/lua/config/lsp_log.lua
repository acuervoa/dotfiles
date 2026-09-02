local M = {}

M.max_bytes = 5 * 1024 * 1024

---Rotate the LSP log when it grows beyond the configured limit.
---@param path string|nil Optional path, useful for tests.
---@return boolean rotated
function M.rotate_if_needed(path)
	path = path or vim.lsp.log.get_filename()
	local stat = vim.uv.fs_stat(path)
	if not stat or stat.size <= M.max_bytes then
		return false
	end

	local ok = vim.uv.fs_rename(path, path .. ".1")
	return ok == true
end

return M
