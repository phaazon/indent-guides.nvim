local M = {}
local vim,api = vim,vim.api
local new_opts = {}

local get_defualt_options = function()
  local default_colors = {
    even = {
      fg = '#2E323A';
      bg = '#34383F';
    };
    odd = {
      fg = '#34383F';
      bg = '#2E323A';
    };
  };

  local default_opts={
    indent_levels = 30;
    indent_guide_size = 1;
    indent_start_level = 1;
    indent_space_guides = true;
    indent_tab_guides = false;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help','dashboard','dashpreview','NvimTree','vista','sagahover'};
    even_colors = default_colors.even;
    odd_colors = default_colors.odd;
  }
  return default_opts
end

local indent_get_matches = function()
  local has_matches,matches = pcall(api.nvim_win_get_var,0,'indent_guides_matches')
  if has_matches then
    return matches
  end
  return {}
end

local indent_clear_matches = function()
  local matches = indent_get_matches()
  if next(matches) ~= nil then
    for _,match_id in ipairs(matches) do
      vim.fn.matchdelete(match_id)
    end
  end
  local status,_ = pcall(vim.api.nvim_win_get_var,0,'indent_guides_matches')
  if status then
    api.nvim_win_del_var(0,'indent_guides_matches')
  end
end

local indent_highlight_color =function ()
  local even = new_opts.even_colors
  local odd = new_opts.odd_colors

  api.nvim_command('hi IndentGuidesEven guifg=' .. even['fg'] .. ' guibg='.. even['bg'])
  api.nvim_command('hi IndentGuidesOdd guifg=' .. odd['fg'] .. ' guibg='.. odd['bg'])
end

local indent_highlight_pattern= function(indent_pattern,column_start,indent_size)
  local pattern = '^'
  pattern = pattern .. indent_pattern .. '*\\%' .. column_start .. 'v\\zs'
  pattern = pattern .. indent_pattern .. '*\\%' .. (column_start + indent_size) .. 'v'
  pattern = pattern .. '\\ze'
  return pattern
end

local has_value = function(tbl,val)
  for _,v in ipairs(tbl) do
    if v == val then
      return true
    end
  end
  return false
end

local render_indent_guides = function()
  local indent_size = 0
  if vim.bo.shiftwidth > 0 and vim.bo.expandtab then
    indent_size = vim.bo.shiftwidth
  else
    indent_size = vim.bo.tabstop
  end

  local guide_size = new_opts['indent_guide_size']
  if guide_size == 0 or guide_size > indent_size then
    guide_size = indent_size
  end

  local level_tbl = vim.fn.range(new_opts['indent_start_level'],new_opts['indent_levels'])
  for _,level in pairs(level_tbl) do
    local group = 'IndentGuides'
    if level % 2 == 0 then
      group = group .. 'Even'
    else
      group = group .. 'Odd'
    end
    local column_start = (level -1 ) * indent_size + 1

    coroutine.yield(group,column_start,guide_size,indent_size)
  end
end

local indent_guides_enable = function()
  local buf_ft = api.nvim_buf_get_option(0,'filetype')

  if has_value(new_opts.exclude_filetypes,buf_ft) then
    indent_clear_matches()
    return
  end

  if next(indent_get_matches()) ~= nil then
    return
  end

  indent_highlight_color()

  local indent_guides = coroutine.create(render_indent_guides)
  local matches = {}
  local indent_render = function()
    while true do
      local _,group,column_start,guide_size,indent_size = coroutine.resume(indent_guides)
      if column_start ~= nil then
        if new_opts['indent_space_guides'] then
          local soft_pattern = indent_highlight_pattern(new_opts['indent_soft_pattern'],column_start,guide_size)
          table.insert(matches,vim.fn.matchadd(group,soft_pattern))
        end
        if new_opts['indent_tab_guides'] then
          local hard_pattern = indent_highlight_pattern('\\t',column_start,indent_size)
          table.insert(matches,vim.fn.matchadd(group,hard_pattern))
        end
      end
      if coroutine.status(indent_guides) == 'dead' then
        break
      end
    end
  end

  indent_render()
  api.nvim_win_set_var(0,'indent_guides_matches',matches)
end

local indent_enabled = true

function M.indent_guides_enable()
  if next(new_opts) == nil then
    M.setup()
  end
  indent_guides_enable()
  if not indent_enabled then
    M.indent_guides_augroup()
  end
end

function M.indent_guides_disable()
  indent_enabled = false
  indent_clear_matches()
  vim.api.nvim_command('augroup indent_guides_nvim')
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command('augroup END')
end

function M.setup(user_opts)
  local opts = user_opts or {}
  new_opts = vim.tbl_extend('force',get_defualt_options(),opts)
end

function  M.indent_guides_augroup()
  api.nvim_command('augroup indent_guides_nvim')
  api.nvim_command('autocmd!')
  api.nvim_command('autocmd BufEnter,FileType * lua require("indent_guides").indent_guides_enable()')
  api.nvim_command('augroup END')
end

return M
