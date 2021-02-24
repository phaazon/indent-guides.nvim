## NeoVim Indent Guides

async render indent guides

## Usage

```lua
-- default options
indent_levels = 30;
indent_guide_size = 1;
indent_start_level = 1;
indent_space_guides = true;
indent_tab_guides = false;
indent_soft_pattern = '\\s';
exclude_filetypes = {'help','dashboard','dashpreview','NvimTree','vista','sagahover'};
even_colors = { fg ='#2E323A',bg='#34383F' };
odd_colors = {fg='#34383F',bg='#2E323A'};

lua require('indent_guides').setup({
  -- put your options in here
})
```

## Preview

![QQ20210224-214759](https://user-images.githubusercontent.com/41671631/109009920-1e6fcb80-76ea-11eb-82e8-a2f4c72c6014.png)

## Acknowledgement

[nathanaelkane/vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
