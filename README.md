linefly statusline
==================

_linefly statusline_ is a simple, fast and informative `statusline` for Vim and
Neovim.

_linefly statusline_ also provides optional `tabline` and Neovim
`winbar` support when the appropriate settings are enabled; refer to
[`lineflyTabLine`](https://github.com/bluz71/vim-linefly-statusline#lineflywinbar)
and
[`lineflyWinBar`](https://github.com/bluz71/vim-linefly-statusline#lineflywinbar).

_linefly statusline_ will adapt it's colors to the colorscheme currently in
effect. Colors can also be
[customized](https://github.com/bluz71/vim-linefly-statusline#highlight-groups-and-colors)
if desired.

Lastly, _linefly statusline_ is a light _statusline_ plugin clocking in at
about 500 lines of code. For comparison, the
[lightline](https://github.com/itchyny/lightline.vim),
[airline](https://github.com/vim-airline/vim-airline) and
[lualine](https://github.com/nvim-lualine/lualine.nvim) `statusline` plugins
contain over 3,600, 7,900 and 7,300 lines of code respectively. In fairness, the
latter plugins are more featureful, configurable and visually pleasing.

Screenshots
-----------

![normal](https://raw.githubusercontent.com/bluz71/misc-binaries/master/mistfly/mistfly-normal.png)
![insert](https://raw.githubusercontent.com/bluz71/misc-binaries/master/mistfly/mistfly-insert.png)
![visual](https://raw.githubusercontent.com/bluz71/misc-binaries/master/mistfly/mistfly-visual.png)
![command](https://raw.githubusercontent.com/bluz71/misc-binaries/master/mistfly/mistfly-command.png)
![replace](https://raw.githubusercontent.com/bluz71/misc-binaries/master/mistfly/mistfly-replace.png)

The above screenshots are using the
[nightfly](https://github.com/bluz71/vim-nightfly-colors) colorscheme and the
[Iosevka](https://github.com/be5invis/Iosevka) font with a couple Git changes,
a single Diagnostic warning and indent-status enabled.

Statusline Performance Comparison
---------------------------------

A performance comparison of _linefly stautusline_ against various popular
`statusline` plugins, with their out-of-the-box defaults, on a clean and minimal
Neovim setup with the [moonfly](https://github.com/bluz71/vim-moonfly-colors)
colorscheme. The Neovim startup times in the following table are provived by the
[dstein64/vim-startuptime](https://github.com/dstein64/vim-startuptime) plugin.

Startup times are the average of five consecutive runs. Note, `native` is run
without any `statusline` plugin.

| native  | linefly | lightline | airline | lualine
|---------|---------|-----------|---------|--------
| 19.0ms  | 21.8ms  | 24.5ms    | 95.0ms  | 30.8ms

Startup times as of July 2022 on my system; performance on other systems will
vary.

Plugins, Linters and Diagnostics supported
------------------------------------------

- [vim-devicons](https://github.com/ryanoasis/vim-devicons) and
  [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) via the
  `lineflyWithFileIcon` option

- [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)

- [Neovim Diagnostic](https://neovim.io/doc/user/diagnostic.html)

- [Obsession](https://github.com/tpope/vim-obsession)

:zap: Requirements
------------------

_linefly statusline_ requires a **GUI** capable version of Vim or Neovim with an
appropriate `colorscheme` set.

A GUI client, such as Gvim, or a modern terminal version of Vim or Neovim with
`termguicolors` enabled in a true-color terminal, is required.

I encourage terminal users to use a true-color terminal, such as:
[iTerm2](https://iterm2.com),
[Alacritty](https://github.com/alacritty/alacritty)
[Windows Terminal](https://github.com/microsoft/terminal), or
[kitty](https://sw.kovidgoyal.net/kitty/index.html) and enable the
`termguicolors` option.

Installation
------------

Install **bluz71/nvim-linefly** with your preferred plugin manager.

[vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'bluz71/nvim-linefly'
```

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'bluz71/nvim-linefly'
```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ 'bluz71/nvim-linefly' },
```

Notice
------

File explorers, such as _NERDTree_, _netrw_ and certain other special buffers,
will have their statusline blanked out by this plugin.

Layout And Default Colors
-------------------------

The *linefly-statusline* layout consists of two main groupings, the left-side
and right-side groups as follows:

```
+-------------------------------------------------+
| A | B | C | D                         X | Y | Z |
+-------------------------------------------------+
```

| Section | Purpose
|---------|------------------
| A`*`    | Mode status (normal, insert, visual, command and replace modes)
| B       | Compacted filename (see below for details)
| C`*`    | Git repository branch name (if applicable)
| D`*`    | Plugins notification (git, diagnostic and session status)
| X       | Current position
| Y`*`    | Total lines and current location as percentage
| Z       | Optional indent status (spaces and tabs shift width)

Sections marked with a `*` are linked to a highlight group and are colored,
refer to the next section for details.

Note, filenames will be compacted as follows:

- Pathless filenames only for files in the current working directory

- Relative paths in preference to absolute paths for files not in the current
  working directory

- `~`-style home directory paths in preference to absolute paths

- Shortened, for example `foo/bar/bazz/hello.txt` will be displayed as
  `f/b/b/hello.txt`, but not when Neovim's global statusline (`set
  laststatus=3`) is in effect.

- Trimmed, a maximum of four path components will be displayed for a filename,
  if a filename is more deeply nested then only the four most significant
  components, including the filename, will be displayed with an ellipses `...`
  prefix used to indicate path trimming.

Highlight Groups And Colors
---------------------------

Sections marked with `*` in the previous section are linked to the following
custom highlight groups with their associated fallbacks if the current
colorscheme does not support _linefly statusline_.

| Segment                  | Custom Highlight Group | Synthesized Highlight Fallback
|--------------------------|------------------------|-------------------------------
| Normal Mode              | `LineflyNormal`        | `Directory`
| Insert Mode              | `LineflyInsert`        | `String`
| Visual Mode              | `LineflyVisual`        | `Statement`
| Command Mode             | `LineflyCommand`       | `WarningMsg`
| Replace Mode             | `LineflyReplace`       | `Error`

Note, the following colorschemes support _linefly statusline_, either within the
colorscheme (moonfly & nightfly) or within this plugin (all others):

- [moonfly](https://github.com/bluz71/vim-moonfly-colors)

- [nightfly](https://github.com/bluz71/vim-nightfly-guicolors)

- [catppuccin](https://github.com/catppuccin/nvim)

- [dracula](https://github.com/dracula/vim)

- [edge](https://github.com/sainnhe/edge)

- [embark](https://github.com/embark-theme/vim)

- [everforest](https://github.com/sainnhe/everforest)

- [gruvbox](https://github.com/gruvbox-community/gruvbox)

- [gruvbox-material](https://github.com/sainnhe/gruvbox-material)

- [nightfox](https://github.com/EdenEast/nightfox.nvim)

- [sonokai](https://github.com/sainnhe/sonokai)

- [tokyonight](https://github.com/folke/tokyonight.nvim)

Lastly, if the fallback colors do not suit then it is very easy to override with
your own highlights.

:gift: Here is a simple example of customized _linefly statusline_ colors. Save
the following either at the end of your initialization file, after setting your
`colorscheme`, or in an appropriate `after` file such as
`after/plugin/linefly-statusline.vim`.

```viml
highlight! link LineflyNormal DiffChange
highlight! link LineflyInsert WildMenu
highlight! link LineflyVisual IncSearch
highlight! link LineflyCommand WildMenu
highlight! link LineflyReplace ErrorMsg
```

:wrench: Options
----------------

| Option | Default State
|--------|--------------
| [lineflyAsciiShapes](https://github.com/bluz71/vim-linefly-statusline#lineflyasciishapes)                           | Disabled, do display Unicode shapes
| [lineflyErrorSymbol](https://github.com/bluz71/vim-linefly-statusline#lineflyerrorsymbol)                           | `x`
| [lineflyWarningSymbol](https://github.com/bluz71/vim-linefly-statusline#lineflywarningsymbol)                       | `!`
| [lineflyInformationSymbol](https://github.com/bluz71/vim-linefly-statusline#lineflyinformationsymbol)               | `i`
| [lineflyTabLine](https://github.com/bluz71/vim-linefly-statusline#lineflytabline)                                   | Disabled
| [lineflyWinBar](https://github.com/bluz71/vim-linefly-statusline#lineflywinbar)                                     | Disabled
| [lineflyWithIndentStatus](https://github.com/bluz71/vim-linefly-statusline#lineflywithindentstatus)                 | Disabled
| [lineflyWithGitBranch](https://github.com/bluz71/vim-linefly-statusline#lineflywithgitbranch)                       | Enabled
| [lineflyWithGitsignsStatus](https://github.com/bluz71/vim-linefly-statusline#lineflywithgitsignsstatus)             | Enabled if Gitsigns plugin is loaded
| [lineflyWithNvimDiagnosticStatus](https://github.com/bluz71/vim-linefly-statusline#lineflywithnvimdiagnosticstatus) | Enabled if nvim-lspconfig plugin is loaded

---

### lineflyAsciiShapes

The `lineflyAsciiShapes` option specifies whether to only use Ascii characters
for certain dividers and symbols.

_linefly statusline_ by default **will use** Unicode Symbols and Powerline
Glyphs for certain shapes such as: Git branch, dividers and active tabs. Note,
many modern fonts, such as: [Hack](https://sourcefoundry.org/hack),
[Iosevka](https://typeof.net/Iosevk), [Fira
Code](https://github.com/tonsky/FiraCode) and [Jetbrains
Mono](https://www.jetbrains.com/lp/mono), will provide these shapes.

To limit use only to Ascii shapes please add the following to your
initialization file:

```viml
" Vimscript initialization file
let g:lineflyAsciiShapes = v:true
```

```lua
-- Lua initialization file
vim.g.lineflyAsciiShapes = true
```

---

### lineflyErrorSymbol

The `lineflyErrorSymbol` option specifies which character symbol to use when
displaying [Neovim Diagnostic](https://neovim.io/doc/user/diagnostic.html),
[ALE](https://github.com/dense-analysis/ale) or
[Coc](https://github.com/neoclide/coc.nvim) errors.

By default, the `x` character, will be displayed.

To specify your own error symbol please add the following to your initialization
file:

```viml
" Vimscript initialization file
let g:lineflyErrorSymbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
```

```lua
-- Lua initialization file
vim.g.lineflyErrorSymbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
```

---

### lineflyWarningSymbol

The `lineflyWarningSymbol` option specifies which character symbol to use when
displaying [Neovim Diagnostic](https://neovim.io/doc/user/diagnostic.html),
[ALE](https://github.com/dense-analysis/ale) or
[Coc](https://github.com/neoclide/coc.nvim) warnings.

By default, the exclamation symbol, `!`, will be displayed.

To specify your own warning symbol please add the following to your
initialization file:

```viml
" Vimscript initialization file
let g:lineflyWarningSymbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
```

```lua
-- Lua initialization file
vim.g.lineflyWarningSymbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
```

---

### lineflyInformationSymbol

The `lineflyInformationSymbol` option specifies which character symbol to use
when displaying [Neovim Diagnostic](https://neovim.io/doc/user/diagnostic.html),
[ALE](https://github.com/dense-analysis/ale) or
[Coc](https://github.com/neoclide/coc.nvim) information.

By default, the exclamation symbol, `i`, will be displayed.

To specify your own information symbol please add the following to your
initialization file:

```viml
" Vimscript initialization file
let g:lineflyInformationSymbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
```

```lua
-- Lua initialization file
vim.g.lineflyInformationSymbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
```

---

### lineflyTabLine

The `lineflyTabLine` option specifies whether to let this plugin manage the
`tabline` in addition to the `statusline`. By default `tabline` management will
not be undertaken.

If enabled, _linefly statusline_ will render a simple numbered, and clickable,
window-space layout in the `tabline`; note, no buffers will be displayed in the
`tabline` since there are many plugins that already provide that capability.

To enable _linefly statusline_'s `tabline` support please add the following to
your initialization file:

```viml
" Vimscript initialization file
let g:lineflyTabLine = v:true
```

```lua
-- Lua initialization file
vim.g.lineflyTabLine = true
```

:bulb: Mappings, such as the following, may be useful to quickly switch between
the numbered window-spaces:

```viml
nnoremap <Leader>1 1gt
nnoremap <Leader>2 2gt
nnoremap <Leader>3 3gt
nnoremap <Leader>4 4gt
nnoremap <Leader>5 5gt
nnoremap <Leader>6 6gt
nnoremap <Leader>7 7gt
nnoremap <Leader>8 8gt
nnoremap <Leader>9 9gt
```

A screenshot of the `tabline`:

![tabline](https://raw.githubusercontent.com/bluz71/misc-binaries/master/linefly/linefly-tabline.png)

---

### lineflyWinBar

The `lineflyWinBar` option specifies whether to display Neovim's window bar at
the top of each window. By default window bars will not be displayed.

Note, Neovim 0.8 (or later) is required for this feature.

Displaying a window bar is reasonable when Neovim's global statusline is enabled
via `set laststatus=3`; the `winbar` will then display the file name at the top
of each window to disambiguate splits. Also, if there only one window in the
current tab then a `winbar` will not be displayed (it won't be needed).

To enable Neovim's `winbar` feature please add the following to your
initialization file:

```viml
" Vimscript initialization file
let g:lineflyWinBar = v:true
```

```lua
-- Lua initialization file
vim.g.lineflyWinBar = true
```

---

### lineflyWithIndentStatus

The `lineflyWithIndentStatus` option specifies whether to display the
indentation status as the last component in the statusline. By default
indentation status will not be displayed.

Note, if the `expandtab` option is set, for the current buffer, then tab stop
will be displayed, for example `Tab:4` (tab equals four spaces); if on the other
hand `noexpandtab` option is set then shift width will be displayed instead, for
example `Spc:2` ('spc' short for 'space').

To enable indentation status please add the following to your initialization
file:

```viml
" Vimscript initialization file
let g:lineflyWithIndentStatus = v:true
```

```lua
-- Lua initialization file
vim.g.lineflyWithIndentStatus = true
```

---

### lineflyWithGitBranch

The `lineflyWithGitBranch` option specifies whether to display Git branch
details in the _statusline_. By default Git branches will be displayed in the
`statusline`.

To disable the display of Git branches in the _statusline_ please add the
following to your initialization file:

```viml
" Vimscript initialization file
let g:lineflyWithGitBranch = v:false
```

```lua
-- Lua initialization file
vim.g.lineflyWithGitBranch = false
```

---

### lineflyWithGitsignsStatus

The `lineflyWithGitsignsStatus` option specifies whether to display
[Gitsigns](https://github.com/lewis6991/gitsigns.nvim) of the current buffer in
the _statusline_.

By default, Gitsigns will be displayed if the plugin is loaded.

To disable the display of Gitsigns in the _statusline_ please add the following
to your initialization file:

```viml
" Vimscript initialization file
let g:lineflyWithGitsignsStatus = v:false
```

```lua
-- Lua initialization file
vim.g.lineflyWithGitsignsStatus = false
```

---

### lineflyWithFileIcon

The `lineflyWithFileIcon` option specifies whether a filetype icon, from a Nerd
Font, will be displayed prior to the filename in the `statusline` (and optional
`winbar`).

Note, a [Nerd Font](https://www.nerdfonts.com) must be active **and** the
[vim-devicons](https://github.com/ryanoasis/vim-devicons) or
[nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) plugin must
be installed and active.

By default a filetype icon will not be displayed in the `statusline`.

To display a filetype icon please add the following to your initialization file:

```viml
" Vimscript initialization file
let g:lineflyWithFileIcon = v:true
```

```lua
-- lua initialization file
vim.g.lineflyWithFileIcon = true
```

---

### lineflyWithNvimDiagnosticStatus

_linefly statusline_ supports [Neovim
Diagnostics](https://neovim.io/doc/user/diagnostic.html)

The `lineflyWithNvimDiagnosticStatus` option specifies whether to indicate the
presence of the Neovim Diagnostics in the current buffer.

By default, Neovim Diagnositics will be displayed if the
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) plugin is loaded.

If Neovim Diagnostic display is not wanted then please add the following to
your initialization file:

```viml
" Vimscript initialization file
let g:lineflyWithNvimDiagnosticStatus = v:false
```

```lua
-- Lua initialization file
vim.g.lineflyWithNvimDiagnosticStatus = false
```

Sponsor
-------

[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/bluz71)

License
-------

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
