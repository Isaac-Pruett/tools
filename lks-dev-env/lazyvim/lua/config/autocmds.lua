-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
local search_highlight_group = vim.api.nvim_create_augroup("lks_search_highlights", { clear = true })

local function set_search_highlights()
  vim.api.nvim_set_hl(0, "Search", { fg = "#000000", bg = "#FCE566", bold = true })
  vim.api.nvim_set_hl(0, "IncSearch", { fg = "#000000", bg = "#FD9353", bold = true })
  vim.api.nvim_set_hl(0, "CurSearch", { fg = "#000000", bg = "#FD9353", bold = true })
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = search_highlight_group,
  callback = set_search_highlights,
})
