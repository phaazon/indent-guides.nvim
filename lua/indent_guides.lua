local M = {}
local vim,api = vim,vim.api

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

M.options = {
    indent_levels = 30;
    indent_guide_size = 0;
    indent_start_level = 1;
    indent_space_guides = true;
    indent_tab_guides = false;
    indent_pretty_guides = false;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help','dashboard','dashpreview'};
    even_colors = default_colors.even;
    odd_colors = default_colors.odd;
}

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
  local new_opts = M.options
  local even_colors = new_opts.even_colors or {}
  local odd_colors = new_opts.odd_colors or {}

  local even = {
    even_colors.fg or default_colors.even.fg,
    even_colors.bg or default_colors.even.bg,
  }
  local odd = {
    odd_colors.fg or default_colors.odd.fg,
    odd_colors.bg or default_colors.odd.bg,
  }

  api.nvim_command('hi IndentGuidesEven guifg=' .. even[1] .. ' guibg='.. even[2])
  api.nvim_command('hi IndentGuidesOdd guifg=' .. odd[1] .. ' guibg='.. odd[2])
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
  local new_opts = M.options
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
  local new_opts = M.options
  local buf_ft = vim.api.nvim_buf_get_option(0,'filetype')

  if has_value(new_opts.exclude_filetypes,buf_ft) then
    indent_clear_matches()
    return
  end

  indent_highlight_color()
  local matches = indent_get_matches()
  local indent_guides = coroutine.create(render_indent_guides)

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

function  M.indent_guides_augroup()
  local definition = {'BufEnter','FileType'}
  vim.api.nvim_command('augroup indent_guides_nvim')
  vim.api.nvim_command('autocmd!')
  for _, def in ipairs(definition) do
    local command = string.format('autocmd %s * lua require("indent_guides").indent_guides_enable()',def)
    vim.api.nvim_command(command)
  end
  vim.api.nvim_command('augroup END')
end

return M
