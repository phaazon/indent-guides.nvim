if exists('g:indent_guides_nvim') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

if !has('nvim')
    echohl Error
    echom "Sorry this plugin only works with versions of neovim that support lua"
    echohl clear
    finish
endif

let g:indent_guides_nvim =1

" Commands
command! -bar IndentGuidesEnable lua require('indent_guides').indent_guides_enable()
command! -bar IndentGuidesDisable lua require('indent_guides').indent_guides_disable()

call v:lua.require('indent_guides').indent_guides_augroup()

let &cpo = s:save_cpo
unlet s:save_cpo
