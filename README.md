## NeoVim Indent Guides

async render indent guides

## Usage

```lua
require('indent_guides').options = {
    indent_levels = 30;
    indent_guide_size = 0;
    indent_start_level = 1;
    indent_space_guides = true;
    indent_tab_guides = true;
    indent_pretty_guides = false;
    indent_soft_pattern = '\\s';
    exclude_filetypes = {'help'}
    even_colors = { fg color , bg color };
    odd_colors = { fg color , bg color };
}
```

`pretty indent mode` is false by default, because now we can't set the virtual text

in first column, So it looks weird to use virtual text to fill the empty lines inside the function

When neovim support virtual text can be set in first column rewrit `pretty mode` and enable it by
default

## TODO

- rainbow mode just like vscode ? we really need this?

## Preview

![1](https://user-images.githubusercontent.com/41671631/99146693-69bf1a80-26b5-11eb-862e-6f9f7edfb715.png)

## Acknowledgement

[nathanaelkane/vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
