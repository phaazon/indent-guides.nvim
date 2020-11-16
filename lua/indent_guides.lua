local M = {}
local vim,api = vim,vim.api

M.options = {
    indent_levels = 30;
    indent_guide_size = 0;
    indent_start_level = 1;
    indent_space_guides = true;
    indent_tab_guides = false;
    indent_pretty_guides = false;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help','dashboard','terminal'};
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
  api.nvim_win_del_var(0,'indent_guides_matches')
end

local indent_highlight_color =function ()
  local even = {'#2E323A','#34383F'}
  local odd = {'#34383F','#2E323A'}
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

local indent_guides_enable = function()
  local new_opts = M.options
  local buf_ft = vim.bo.filetype

  if has_value(new_opts.exclude_filetypes,buf_ft) then
    return
  end

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

  indent_highlight_color()

  local matches = indent_get_matches()
  local level_tbl = vim.fn.range(new_opts['indent_start_level'],new_opts['indent_levels'])
  for _,level in pairs(level_tbl) do
    local group = 'IndentGuides'
    if level % 2 == 0 then
      group = group .. 'Even'
    else
      group = group .. 'Odd'
    end
    local column_start = (level -1 ) * indent_size + 1

    if new_opts['indent_space_guides']  then
      local soft_pattern = indent_highlight_pattern(new_opts['indent_soft_pattern'],column_start,guide_size)
      table.insert(matches,vim.fn.matchadd(group,soft_pattern))
    end

    if new_opts['indent_tab_guides'] then
      local hard_pattern = indent_highlight_pattern('\\t',column_start,indent_size)
      table.insert(matches,vim.fn.matchadd(group,hard_pattern))
    end
  end
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
  local definition = {'BufRead','FileType'}
  vim.api.nvim_command('augroup indent_guides_nvim')
  vim.api.nvim_command('autocmd!')
  for _, def in ipairs(definition) do
    local command = string.format('autocmd %s * lua require("indent_guides").indent_guides_enable()',def)
    vim.api.nvim_command(command)
  end
  vim.api.nvim_command('augroup END')
end

return M
