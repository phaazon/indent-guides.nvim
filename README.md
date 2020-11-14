## NeoVim Indent Guides

rewrite [nathanaelkane/vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)

using lua with support pretty indent mode  and rainbow indent mode

## Usage

```lua
require('indent_guides').default_opts = {
    indent_levels = 30;
    indent_guide_size = 0;
    indent_start_level = 1;
    indent_space_guides = true;
    indent_tab_guides = true;
    indent_pretty_guides = false;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help'}
}
```

## Preview

![1](https://user-images.githubusercontent.com/41671631/99146693-69bf1a80-26b5-11eb-862e-6f9f7edfb715.png)
