local M = {}

local CONFIG = {
	render_interval_ms = 80,
	window_ratio = 0.8,
	cmd_safe = {
		"codex",
		"exec",
		"--skip-git-repo-check",
	},
	cmd_agent = {
		"codex",
		"exec",
		"--skip-git-repo-check",
		"--full-auto",
	},
}

local SAFE_PREFIX = [[
You are in STRICT MODE.

Rules:
- DO NOT execute shell commands
- DO NOT inspect filesystem
- DO NOT search for files
- DO NOT Infer missing context
- ONLY use the input provided below

If information is missing, say it explicitly.
---
]]

local SPINNER_FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local PROMPTS = {
	explain = [[
Explica este código como backend senior:
- qué hace
- problemas potenciales
- mejoras

]],
	refactor = [[
Refactoriza aplicando:
- SRP
- claridad
- rendimiento
Sin romper contratos

]],
	fix = [[
Analiza este código:
- causa raíz
- fix exacto
- impacto en contratos API

]],
	diff = [[
Analiza este diff:
- bugs
- breaking changes
- mejoras

]],
	visual = [[
Analiza este fragmento:
- qué hace
- problemas
- mejoras

]],
	repo = [[
Analiza este repositorio como backend senior.

Devuelve:
- arquitectura general
- módulos principales
- flujos de datos
- problemas potenciales
- mejoras recomendadas
- riesgos técnicos

No pidas confirmación. Analiza directamente el proyecto.
]],
}

local DEFAULT_COMMANDS = {
	Codex = "prompt",
	CodexExplain = "explain",
	-- Compat: se mantiene typo histórico
	CodexExplainReoi = "explain_repo",
	-- Alias correcto (nuevo, no rompe compatibilidad)
	CodexExplainRepo = "explain_repo",
	CodexFix = "fix",
	CodexRefactor = "refactor",
	CodexDiff = "diff",
	CodexVisual = "visual",
}

local COMMAND_DESCRIPTIONS = {
	Codex = "Ejecuta prompt libre con Codex",
	CodexExplain = "Explica el archivo actual",
	CodexExplainReoi = "Explica el repositorio (compat)",
	CodexExplainRepo = "Explica el repositorio",
	CodexFix = "Analiza bugs y fixes del archivo",
	CodexRefactor = "Sugiere refactor del archivo",
	CodexDiff = "Analiza el diff git actual",
	CodexVisual = "Analiza la selección visual",
}

local ACTIVE_SESSION = nil

local function merge_table_if_present(dst, src, key)
	if type(src[key]) == "table" then
		dst[key] = vim.deepcopy(src[key])
	end
end

local function apply_config(opts)
	if type(opts) ~= "table" then
		return
	end

	if type(opts.render_interval_ms) == "number" and opts.render_interval_ms > 0 then
		CONFIG.render_interval_ms = opts.render_interval_ms
	end

	if type(opts.window_ratio) == "number" and opts.window_ratio > 0 and opts.window_ratio <= 1 then
		CONFIG.window_ratio = opts.window_ratio
	end

	merge_table_if_present(CONFIG, opts, "cmd_safe")
	merge_table_if_present(CONFIG, opts, "cmd_agent")

	if type(opts.safe_prefix) == "string" and opts.safe_prefix ~= "" then
		SAFE_PREFIX = opts.safe_prefix
	end

	if type(opts.spinner_frames) == "table" and #opts.spinner_frames > 0 then
		SPINNER_FRAMES = vim.deepcopy(opts.spinner_frames)
	end

	if type(opts.prompts) == "table" then
		for key, value in pairs(opts.prompts) do
			if PROMPTS[key] ~= nil and type(value) == "string" then
				PROMPTS[key] = value
			end
		end
	end
end

local function create_session()
	return {
		buf = nil,
		win = nil,
		job_id = nil,
		output = {},
		raw = {},
		spinner_timer = nil,
		spinner_active = false,
		last_render = 0,
	}
end

local function is_git_repo()
	return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")
end

local function append_non_empty(target, items)
	if type(items) ~= "table" then
		return
	end

	for _, item in ipairs(items) do
		if item and item ~= "" then
			table.insert(target, item)
		end
	end
end

local function stop_spinner(session)
	session.spinner_active = false
	if session.spinner_timer then
		session.spinner_timer:stop()
		session.spinner_timer:close()
		session.spinner_timer = nil
	end
end

local function close_session(session)
	if not session then
		return
	end

	stop_spinner(session)

	if session.job_id then
		vim.fn.jobstop(session.job_id)
		session.job_id = nil
	end

	if session.win and vim.api.nvim_win_is_valid(session.win) then
		vim.api.nvim_win_close(session.win, true)
	end

	session.win = nil
	session.buf = nil

	if ACTIVE_SESSION == session then
		ACTIVE_SESSION = nil
	end
end

local function create_active_session()
	if ACTIVE_SESSION then
		close_session(ACTIVE_SESSION)
	end

	local session = create_session()
	ACTIVE_SESSION = session
	return session
end

local function ensure_window(session)
	if session.win and vim.api.nvim_win_is_valid(session.win) then
		return session.buf
	end

	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * CONFIG.window_ratio)
	local height = math.floor(vim.o.lines * CONFIG.window_ratio)

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		border = "rounded",
	})

	vim.bo[buf].filetype = "markdown"
	vim.wo[win].wrap = true

	vim.keymap.set("n", "q", function()
		close_session(session)
	end, { buffer = buf, silent = true })

	vim.keymap.set("n", "<Esc>", function()
		close_session(session)
	end, { buffer = buf, silent = true })

	session.buf = buf
	session.win = win

	return buf
end

local function render(session, force)
	local now = vim.loop.now()
	if not force and (now - session.last_render < CONFIG.render_interval_ms) then
		return
	end

	session.last_render = now

	local ok, buf = pcall(ensure_window, session)
	if not ok or not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, session.output)
	vim.bo[buf].modifiable = false
end

local function start_spinner(session, message)
	stop_spinner(session)
	session.spinner_active = true

	local i = 1
	session.output = { "⏳ " .. message }
	render(session, true)

	session.spinner_timer = vim.loop.new_timer()
	session.spinner_timer:start(
		0,
		CONFIG.render_interval_ms,
		vim.schedule_wrap(function()
			if not session.spinner_active then
				return
			end

			session.output[1] = SPINNER_FRAMES[i] .. " " .. message
			i = (i % #SPINNER_FRAMES) + 1
			render(session)
		end)
	)
end

local function clean_output(lines)
	local result = {}
	local started = false

	for _, line in ipairs(lines or {}) do
		if line:match("^codex$") then
			started = true
		elseif line:match("^tokens used") then
			break
		elseif started then
			table.insert(result, line)
		end
	end

	if #result == 0 then
		return lines or {}
	end

	return result
end

local function append_data(session, data)
	if not data then
		return
	end

	append_non_empty(session.raw, data)
	append_non_empty(session.output, data)
	render(session)
end

local function get_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end

local function normalize_selection_range(start_pos, end_pos)
	if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
		return end_pos, start_pos
	end

	return start_pos, end_pos
end

local function get_visual(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local s = vim.fn.getpos("'<")
	local e = vim.fn.getpos("'>")
	s, e = normalize_selection_range(s, e)

	local lines = vim.api.nvim_buf_get_lines(bufnr, s[2] - 1, e[2], false)
	if #lines == 0 then
		return ""
	end

	lines[1] = string.sub(lines[1], s[3])
	lines[#lines] = string.sub(lines[#lines], 1, e[3])

	return table.concat(lines, "\n")
end

local function get_diff_async(cb)
	vim.fn.jobstart({ "git", "diff" }, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			cb(table.concat(data or {}, "\n"))
		end,
		on_stderr = function(_, _)
			-- noop: mantenemos comportamiento actual (solo salida en stdout)
		end,
	})
end

local function make_prompt(prefix, content)
	return (prefix or "") .. (content or "")
end

local function has_non_whitespace(content)
	return type(content) == "string" and content:match("%S") ~= nil
end

local function render_error(session, message)
	session.output = { message }
	render(session, true)
end

local function run_codex(session, prompt, mode)
	if vim.fn.executable("codex") ~= 1 then
		session.output = { "[codex no encontrado en PATH]" }
		render(session, true)
		return
	end

	local base_cmd = (mode == "agent") and CONFIG.cmd_agent or CONFIG.cmd_safe
	local cmd = vim.deepcopy(base_cmd)
	table.insert(cmd, prompt)

	session.job_id = vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		stderr_buffered = false,

		on_stdout = function(_, data)
			append_data(session, data)
		end,

		on_stderr = function(_, data)
			append_data(session, data)
		end,

		on_exit = function(_, code)
			stop_spinner(session)
			session.job_id = nil

			session.output = clean_output(session.raw)
			if code ~= 0 then
				table.insert(session.output, "")
				table.insert(session.output, "[exit code " .. code .. "]")
			end

			vim.schedule(function()
				render(session, true)
			end)
		end,
	})

	if session.job_id <= 0 then
		stop_spinner(session)
		session.job_id = nil
		session.output = { "[error iniciando codex]" }
		render(session, true)
	end
end

function M.setup(opts)
	apply_config(opts or {})

	if opts and opts.commands ~= false then
		M.register_commands(opts.commands)
	end
end

function M.register_commands(opts)
	local force = type(opts) == "table" and opts.force == true
	local commands = DEFAULT_COMMANDS

	if type(opts) == "table" and type(opts.map) == "table" then
		commands = vim.tbl_extend("force", vim.deepcopy(DEFAULT_COMMANDS), opts.map)
	end

	for name, method in pairs(commands) do
		local fn = M[method]
		if type(fn) == "function" then
			if force and vim.fn.exists(":" .. name) == 2 then
				pcall(vim.api.nvim_del_user_command, name)
			end

			if vim.fn.exists(":" .. name) ~= 2 then
				vim.api.nvim_create_user_command(name, fn, { desc = COMMAND_DESCRIPTIONS[name] })
			end
		end
	end
end

function M.prompt()
	vim.ui.input({ prompt = "Codex Prompt: " }, function(input)
		if not input or input == "" then
			return
		end

		local session = create_active_session()
		start_spinner(session, "Ejecutando Codex...")
		run_codex(session, input)
	end)
end

function M.explain()
	local source_buf = vim.api.nvim_get_current_buf()
	local code = get_buffer(source_buf)

	local session = create_active_session()
	if not has_non_whitespace(code) then
		render_error(session, "[El archivo actual está vacío]")
		return
	end

	start_spinner(session, "Analizando archivo...")

	local prompt = make_prompt(SAFE_PREFIX .. PROMPTS.explain, code)
	run_codex(session, prompt, "safe")
end

function M.explain_repo()
	local session = create_active_session()

	if not is_git_repo() then
		session.output = { "[No estás dentro de un repo git]" }
		render(session, true)
		return
	end

	start_spinner(session, "Analizando repositorio...")
	run_codex(session, PROMPTS.repo, "agent")
end

function M.fix()
	local source_buf = vim.api.nvim_get_current_buf()
	local code = get_buffer(source_buf)

	local session = create_active_session()
	if not has_non_whitespace(code) then
		render_error(session, "[El archivo actual está vacío]")
		return
	end

	start_spinner(session, "Detectando errores...")

	local prompt = make_prompt(PROMPTS.fix, code)
	run_codex(session, prompt)
end

function M.refactor()
	local source_buf = vim.api.nvim_get_current_buf()
	local code = get_buffer(source_buf)

	local session = create_active_session()
	if not has_non_whitespace(code) then
		render_error(session, "[El archivo actual está vacío]")
		return
	end

	start_spinner(session, "Refactorizando...")

	local prompt = make_prompt(PROMPTS.refactor, code)
	run_codex(session, prompt)
end

function M.diff()
	local session = create_active_session()
	start_spinner(session, "Analizando diff...")

	get_diff_async(function(diff)
		if not has_non_whitespace(diff) then
			render_error(session, "[No hay cambios en git diff]")
			return
		end

		local prompt = make_prompt(PROMPTS.diff, diff)
		run_codex(session, prompt)
	end)
end

function M.visual()
	local source_buf = vim.api.nvim_get_current_buf()
	local code = get_visual(source_buf)

	local session = create_active_session()
	if not has_non_whitespace(code) then
		render_error(session, "[No hay selección visual]")
		return
	end

	start_spinner(session, "Analizando selección...")

	local prompt = make_prompt(PROMPTS.visual, code)
	run_codex(session, prompt)
end

M.__test = {
	append_non_empty = append_non_empty,
	clean_output = clean_output,
	normalize_selection_range = normalize_selection_range,
	make_prompt = make_prompt,
	has_non_whitespace = has_non_whitespace,
	apply_config = apply_config,
	default_commands = DEFAULT_COMMANDS,
}

return M
