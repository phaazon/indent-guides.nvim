local M = {}
local vim,api = vim,vim.api

local get_default = function ()
  local default_opts = {
    indent_levels = 30;
    indent_guide_size = 0;
    indent_start_level = 1;
    indent_space_guides =1;
    indent_tab_guides =1;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help'}
  }
  return default_opts
end

local indent_get_matches = function()
  local has_matches,matches = pcall(vim.fn.nvim_buf_get_option,'indent_guides_matches')
  if has_matches then
    return matches
  else
    return {}
  end
end

local indent_clear_matches = function()
  local matches = indent_get_matches()
  if next(matches) ~= nil then
    for idx,match_id in pairs(matches) do
      pcall(vim.fn.matchdelete(match_id))
      table.remove(matches,idx)
    end
  end
end

local indent_highlight_color =function ()
  local even = {'#2E323A','#34383F'}
  local odd = {'#34383F','#2E323A'}
  api.nvim_command('hi IndeentGuidesEven guifg=' .. even[1] .. 'guibg='.. even[2])
  api.nvim_command('hi IndeentGuidesOdd guifg=' .. odd[1] .. 'guibg='.. odd[2])
end

local nvim_range = function(_start,_end)
  local tbl = {}
  for i = _start, _end, 1 do
    table.insert(tbl,i)
  end
  return tbl
end

local indent_highlight_pattern= function(indent_pattern,column_start,indent_size)
  local pattern
  pattern = '^' .. indent_pattern .. '*\\%' .. column_start .. 'v\zs'
  pattern = pattern .. indent_pattern .. '*\\%' .. (column_start + indent_size) .. 'v'
  pattern = pattern .. '\ze'
  return pattern
end

local indent_guides_enable = function(opts)
  local default_opts = get_default()
  local indent_namespace = vim.fn.nvim_create_namespace('indent_guides_neovim')
  local buf_ft = vim.bo.filetype
  local new_opts = vim.tbl_extend('keep',default_opts,opts)

  if vim.wo.diff or vim.tbl_contains(new_opts.exclude_filetypes,buf_ft) then
    indent_clear_matches()
    return
  end

  local indent_size
  if vim.bo.shiftwidth > 0 and vim.bo.expandtab then
    indent_size = vim.bo.shiftwidth
  else
    indent_size = vim.bo.expandtab
  end

  local guide_size = new_opts['indent_guide_size']
  if guide_size == 0 or guide_size > indent_size then
    guide_size = indent_size
  end

  indent_highlight_color()
  indent_clear_matches()

  local matches = indent_get_matches()
  local level_tbl = nvim_range(new_opts['indent_start_level'],new_opts['indent_levels'])
  for _,level in pairs(level_tbl) do
    local group = 'IndeentGuides' .. ((level % 2 == 0) and 'Even' or 'Odd')
    local column_start = (level -1 ) * indent_size + 1

    if new_opts['indent_space_guides'] > 0 then
      local soft_pattern = indent_highlight_pattern(new_opts['indent_soft_pattern'],column_start,guide_size)
      table.insert(matches,soft_pattern)
    end

    if new_opts['indent_tab_guides'] > 0 then
      local hard_pattern = indent_highlight_pattern('\t',column_start,indent_size)
      table.insert(matches,vim.fn.matchadd(group,hard_pattern))
    end
  end

  local view = vim.fn.winsaveview()
  vim.fn.cursor(1,1)
  vim.fn.nvim_buf_clear_namespace(0,indent_namespace,1,-1)

  while true do
    local line = vim.fn.search('^$', 'W')
    if line == 0 then
      break
    end

    local idt = vim.fn.cindent(line)
    if idt ~= 0 then
      break
    end

    local guides = {{vim.fn['repeat'](' ',indent_size -1), ''}}
    for _,level in pairs(nvim_range(1,idt / indent_size)) do
      local guide = vim.fn['repeat'](' ',indent_size)
      if level % 2 == 0 then
        table.insert(guides,{guide,'IndentGuidesEven'})
      else
        table.insert(guides,{guide,'IndentGuidesOdd'})
      end
    end
    vim.fn.nvim_buf_set_virtual_text(0,indent_namespace,line - 1,guides,{})
  end
  vim.fn.winrestview(view)
end

local error_handler = function(err)
    if vim.g.indent_blankline_debug then
        vim.api.nvim_command("echohl Error")
        vim.api.nvim_command('echom "' .. err .. '"')
        vim.api.nvim_command("echohl None")
    end
end

M.indent_guides_enable = function(opts)
  local opt = opts or {}
  indent_guides_enable(opt)
end

return M
