-- lua/utils.lua
local M = {}

function M.open_in_float(file_path, pattern)
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.8)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.8)

  local lines
  local use_glow = vim.fn.executable('glow') == 1 and vim.fn.filereadable(file_path) == 1

  if use_glow then
    local cmd = {"glow", "-w", tostring(width), file_path}
    local output = vim.fn.system(cmd)
    lines = vim.fn.split(output, '\n')
  else
    lines = vim.fn.readfile(file_path)
    if vim.v.shell_error ~= 0 then
      print("Error: Could not open file: " .. file_path)
      return
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, file_path)


  local row = math.floor((vim.api.nvim_get_option("lines") - height) / 2)
  local col = math.floor((vim.api.nvim_get_option("columns") - width) / 2)

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set buffer-local keymap for 'q' to close the floating window
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "q",
    ":close<CR>",
    { noremap = true, silent = true }
  )

  vim.api.nvim_win_set_option(win, "cursorline", true)
  vim.api.nvim_buf_set_option(buf, "readonly", true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  if not use_glow then
    vim.api.nvim_win_set_option(win, "conceallevel", 2)
    vim.api.nvim_win_set_option(win, "concealcursor", "n")
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  end

  if pattern then
    -- We need to be in the window to search
    vim.api.nvim_set_current_win(win)
    local cursor_pos = vim.fn.searchpos(pattern, "n")
    if cursor_pos[1] > 0 and cursor_pos[2] > 0 then
      vim.api.nvim_win_set_cursor(win, cursor_pos)
      vim.cmd("normal! zt")
    end
  end
end

return M
