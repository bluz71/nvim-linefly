linefly
=======

_linefly_ is a simple, fast and informative pure-Lua `statusline` for Neovim.

_linefly_ provides optional `tabline` and `winbar` support when the
appropriate settings are enabled; refer to
[`tabline`](https://github.com/bluz71/nvim-linefly#tabline)
and
[`winbar`](https://github.com/bluz71/nvim-linefly#winbar).

_linefly_ will adapt it's colors to the colorscheme currently in effect. Colors
can also be
[customized](https://github.com/bluz71/nvim-linefly#highlight-groups-and-colors)
if desired.

Lastly, _linefly_ is a light `statusline` plugin clocking in at about 600 lines
of Lua code. For comparison, the
[lualine](https://github.com/nvim-lualine/lualine.nvim),
[lightline](https://github.com/itchyny/lightline.vim) and
[airline](https://github.com/vim-airline/vim-airline) plugins contain over
8,000, 3,600 and 7,300 lines of code respectively. In fairness, the latter
plugins are more featureful, configurable and visually pleasing.

:warning: _linefly_ has a predominantly fixed layout, this will **not** be an
appropriate `statusline` plugin if layout flexibility is desired.

Screenshots
-----------

![normal](https://raw.githubusercontent.com/bluz71/misc-binaries/master/statusline/statusline-normal.png)
![insert](https://raw.githubusercontent.com/bluz71/misc-binaries/master/statusline/statusline-insert.png)
![visual](https://raw.githubusercontent.com/bluz71/misc-binaries/master/statusline/statusline-visual.png)
![command](https://raw.githubusercontent.com/bluz71/misc-binaries/master/statusline/statusline-command.png)
![replace](https://raw.githubusercontent.com/bluz71/misc-binaries/master/statusline/statusline-replace.png)

The above screenshots are using the
[moonfly](https://github.com/bluz71/vim-moonfly-colors) colorscheme and the
[Iosevka](https://github.com/be5invis/Iosevka) font with Git changes,
Diagnostics and indent-status enabled.

Statusline Startup Comparison
-----------------------------

A startup comparison of _linefly_ against various popular `statusline`
plugins, with their out-of-the-box defaults, on a clean and minimal Neovim setup
with the [moonfly](https://github.com/bluz71/vim-moonfly-colors) colorscheme.
The Neovim startup times in the following table are provived by the
[dstein64/vim-startuptime](https://github.com/dstein64/vim-startuptime) plugin.

Startup times are the average of five consecutive runs. Note, `stock` is run
without any `statusline` plugin.

| stock  | linefly | lualine | lightline | airline
|--------|---------|---------|-----------|--------
| 20.2ms | 21.1ms  | 26.9ms  | 32.3ms    | 117.6ms

Startup times as of January 2023 on my system; performance on other systems will
vary.

Modules And Plugins supported
-----------------------------

- [Diagnostic](https://neovim.io/doc/user/diagnostic.html)

- [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons)

- [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)

- [vim-obsession](https://github.com/tpope/vim-obsession)

- [possession.nvim](https://github.com/jedrzejboczar/possession.nvim)

- [nvim-possession](https://github.com/gennaro-tedesco/nvim-possession)

:zap: Requirements
------------------

_linefly_ requires Neovim 0.8, or later.

_linefly_ also requires a **GUI** capable version Neovim with an appropriate
`colorscheme` set. A GUI client, or Neovim with the `termguicolors` option
enabled in a true-color terminal, is required.

Lastly, please make sure that the `laststatus` option is set to either: `1`, `2`
or `3`.

Installation
------------

Install **bluz71/nvim-linefly** with your preferred plugin manager.

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'bluz71/nvim-linefly'
```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ 'bluz71/nvim-linefly' },
```

Please do **not** lazy-load _linefly_.

Layout And Default Colors
-------------------------

The *linefly* layout consists of two main groupings, the left-side and
right-side groups as follows:

```
+-------------------------------------------------+
| A | B | C | D                         X | Y | Z |
+-------------------------------------------------+
```

| Section | Purpose
|---------|------------------
| A`*`    | Mode status (normal, insert, visual, command and replace modes)
| B       | Filename (refer below for details)
| C`*`    | Git branch name (if applicable)
| D`*`    | Plugins notification (git, diagnostic and session status)
| X       | Current position
| Y`*`    | Total lines and current location as percentage
| Z       | Optional indent status (spaces and tabs shift width)

Sections marked with a `*` are linked to a highlight group and are colored,
refer to the next section for details.

Note, filenames will be displayed as follows:

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
colorscheme does not support _linefly_.

| Segment                  | Custom Highlight Group | Synthesized Highlight Fallback
|--------------------------|------------------------|-------------------------------
| Normal Mode              | `LineflyNormal`        | `Directory`
| Insert Mode              | `LineflyInsert`        | `String`
| Visual Mode              | `LineflyVisual`        | `Statement`
| Command Mode             | `LineflyCommand`       | `WarningMsg`
| Replace Mode             | `LineflyReplace`       | `Error`

Note, the following colorschemes support _linefly_, either within the
colorscheme (moonfly & nightfly) or within this plugin (all others):

- [moonfly](https://github.com/bluz71/vim-moonfly-colors)

- [nightfly](https://github.com/bluz71/vim-nightfly-guicolors)

- [catppuccin](https://github.com/catppuccin/nvim)

- [dracula](https://github.com/dracula/vim)

- [edge](https://github.com/sainnhe/edge)

- [embark](https://github.com/embark-theme/vim)

- [everforest](https://github.com/sainnhe/everforest)

- [gruvbox](https://github.com/ellisonleao/gruvbox.nvim)

- [gruvbox-material](https://github.com/sainnhe/gruvbox-material)

- [kanagawa](https://github.com/rebelot/kanagawa.nvim)

- [nightfox](https://github.com/EdenEast/nightfox.nvim)

- [rose-pine](https://github.com/rose-pine/neovim)

- [sonokai](https://github.com/sainnhe/sonokai)

- [tokyonight](https://github.com/folke/tokyonight.nvim)

Lastly, if the fallback colors do not suit then it is very easy to override with
your own highlights.

:gift: Here is a simple example of customized _linefly_ colors. Save the
following at the end of your initialization file after setting your
`colorscheme`.

```lua
local highlight = vim.api.nvim_set_hl

highlight(0, "LineflyNormal", { link = "DiffChange" })
highlight(0, "LineflyInsert", { link = "WildMenu" })
highlight(0, "LineflyVisual", { link = "IncSearch" })
highlight(0, "LineflyCommand", { link = "WildMenu" })
highlight(0, "LineflyReplace", { link = "ErrorMsg" })
```

:wrench: Options
----------------

Default option values:

```lua
vim.g.linefly_options = {
  separator_symbol = "⎪",
  progress_symbol = "↓",
  active_tab_symbol = "▪",
  git_branch_symbol = "",
  error_symbol = "E",
  warning_symbol = "W",
  information_symbol = "I",
  tabline = false,
  winbar = false,
  with_file_icon = true,
  with_git_branch = true,
  with_git_status = true,
  with_diagnostic_status = true,
  with_session_status = true,
  with_indent_status = false,
}
```

| Option | Option | Option
|--------|--------|-------
| [separator_symbol](https://github.com/bluz71/nvim-linefly#separator_symbol)             | [progress_symbol](https://github.com/bluz71/nvim-linefly#progress_symbol)         | [active_tab_symbol](https://github.com/bluz71/nvim-linefly#active_tab_symbol)
| [git_branch_symbol](https://github.com/bluz71/nvim-linefly#git_branch_symbol)
| [error_symbol](https://github.com/bluz71/nvim-linefly#error_symbol)                     | [warning_symbol](https://github.com/bluz71/nvim-linefly#warning_symbol)           | [information_symbol](https://github.com/bluz71/nvim-linefly#information_symbol)
| [tabline](https://github.com/bluz71/nvim-linefly#tabline)                               | [winbar](https://github.com/bluz71/nvim-linefly#winbar)
| [with_file_icon](https://github.com/bluz71/nvim-linefly#with_file_icon)                 | [with_git_branch](https://github.com/bluz71/nvim-linefly#with_git_branch)         | [with_git_status](https://github.com/bluz71/nvim-linefly#with_git_status) |
| [with_diagnostic_status](https://github.com/bluz71/nvim-linefly#with_diagnostic_status) | [with_session_status](https://github.com/bluz71/nvim-linefly#with_session_status) | [with_indent_status](https://github.com/bluz71/nvim-linefly#with_indent_status) |

---

### separator_symbol

The `separator_symbol` option specifies which character symbol to use for
segment separators in the `statusline`.

By default, the `⎪` character (Unicode `U+23AA`) will be displayed.

To specify your own separator symbol please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  separator_symbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
}
```

---

### progress_symbol

The `progress_symbol` option specifies which character symbol to use to indicate
location-as-percentage in the `statusline`.

By default, the `↓` character (Unicode `U+2193`) will be displayed.

To specify your own progress symbol, or no symbol at all, please add the
following to your initialization file:

```lua
vim.g.linefly_options = {
  progress_symbol = '<<SYMBOL-OF-YOUR-CHOOSING-OR-EMPTY>>'
}
```

---

### active_tab_symbol

The `active_tab_symbol` option specifies which character symbol to use to
signify the active tab in the `tabline`.

By default, the `▪` character (Unicode `U+25AA`) will be displayed.

To specify your own active tab symbol please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  active_tab_symbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
}
```

---

### git_branch_symbol

The `git_branch_symbol` option specifies which character symbol to use to
signify the active tab in the `tabline`.

By default, the `` character (Powerline `U+E0A0`) will be displayed. Many
modern monospace fonts will contain that character.

To specify your own Git branch symbol, or no symbol at all, please add the
following to your initialization file:

```lua
vim.g.linefly_options = {
  git_branch_symbol = '<<SYMBOL-OF-YOUR-CHOOSING-OR-EMPTY>>'
}
```

---

### error_symbol

The `error_symbol` option specifies which character symbol to use when
displaying [Diagnostic](https://neovim.io/doc/user/diagnostic.html) errors.

By default, the `E` character will be displayed.

To specify your own error symbol please add the following to your initialization
file:

```lua
vim.g.linefly_options = {
  error_symbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
}
```

---

### warning_symbol

The `warning_symbol` option specifies which character symbol to use when
displaying [Diagnostic](https://neovim.io/doc/user/diagnostic.html) warnings.

By default, the `W` character will be displayed.

To specify your own warning symbol please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  warning_symbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
}
```

---

### information_symbol

The `information_symbol` option specifies which character symbol to use
when displaying [Diagnostic](https://neovim.io/doc/user/diagnostic.html)
information.

By default, the `I` character will be displayed.

To specify your own information symbol please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  information_symbol = '<<SYMBOL-OF-YOUR-CHOOSING>>'
}
```

---

### tabline

The _linefly_ `tabline` option specifies whether to let this plugin manage the
Neovim `tabline` in addition to the `statusline`. By default Neovim `tabline`
management will not be undertaken.

If enabled, _linefly_ will render a simple numbered, and clickable, window-space
layout in the `tabline`; note, no buffers will be displayed in the `tabline`
since there are many plugins that already provide that capability.

To enable _linefly_'s `tabline` support please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  tabline = true,
}
```

:bulb: Mappings, such as the following, may be useful to quickly switch between
the numbered window-spaces:

```lua
local map = vim.keymap.set

map("n", "<Leader>1", "1gt")
map("n", "<Leader>2", "2gt")
map("n", "<Leader>3", "3gt")
map("n", "<Leader>4", "4gt")
map("n", "<Leader>5", "5gt")
map("n", "<Leader>6", "6gt")
map("n", "<Leader>7", "7gt")
map("n", "<Leader>8", "8gt")
map("n", "<Leader>9", "9gt")
```

A screenshot of the `tabline`:

![tabline](https://raw.githubusercontent.com/bluz71/misc-binaries/master/statusline/tabline.png)

---

### winbar

The `winbar` option specifies whether to display a window bar at the top of each
window. By default window bars will not be displayed.

Displaying a window bar is recommended when the global statusline is enabled via
`set laststatus=3`; the `winbar` will then display the file name at the top of
each window to disambiguate splits. Also, if there only one window in the
current tab then a `winbar` will not be displayed (it won't be needed).

To enable the `winbar` feature please add the following to your initialization
file:

```lua
vim.g.linefly_options = {
  winbar = true,
}
```

---

### with_file_icon

The `with_file_icon` option specifies whether a filetype icon, from a Nerd
Font, will be displayed prior to the filename in the `statusline` (and optional
`winbar`).

Note, a [Nerd Font](https://www.nerdfonts.com) must be active **and** the
[nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) plugin must
also be installed and active.

By default a filetype icon will be displayed if possible.

To disable the display of a filetype icon please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  with_file_icon = false,
}
```

---

### with_git_branch

The `with_git_branch` option specifies whether to display Git branch
details in the `statusline`. By default Git branches will be displayed in the
`statusline`.

To disable the display of Git branches in the `statusline` please add the
following to your initialization file:

```lua
vim.g.linefly_options = {
  with_git_branch = false,
}
```

---

### with_git_status

The `with_git_status` option specifies whether to display
[Gitsigns](https://github.com/lewis6991/gitsigns.nvim) of the current buffer in
the `statusline`.

By default, the Git status will be displayed if the plugin is loaded.

To disable the display of Git status in the `statusline` please add the
following to your initialization file:

```lua
vim.g.linefly_options = {
  with_git_status = false,
}
```

---

### with_diagnostic_status

_linefly_ supports [Diagnostics](https://neovim.io/doc/user/diagnostic.html).

The `with_diagnostic_status` option specifies whether to indicate the presence
of the Diagnostics in the current buffer.

By default, Diagnositics will be displayed if the
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) plugin is loaded.

If Diagnostic display is not wanted then please add the following to your
initialization file:

```lua
vim.g.linefly_options = {
  with_diagnostic_status = false,
}
```

---

### with_session_status

The `with_session_status` option specifies whether to display
[vim-obsession](https://github.com/tpope/vim-obsession),
[posession.nvim](https://github.com/jedrzejboczar/possession.nvim) or
[nvim-possession](https://github.com/gennaro-tedesco/nvim-possession) session
details in the `statusline`.

By default, session details will be displayed if one of those plugins is loaded.

To disable the display of session details in the `statusline` please add the
following to your initialization file:

```lua
vim.g.linefly_options = {
  with_session_status = false,
}
```

---

### with_indent_status

The `with_indent_status` option specifies whether to display the indentation
status as the last component in the statusline. By default indentation status
will not be displayed.

Note, if the `expandtab` option is set, for the current buffer, then tab stop
will be displayed, for example `Tab:4` (tab equals four spaces); if on the other
hand `noexpandtab` option is set then shift width will be displayed instead, for
example `Spc:2` ('spc' short for 'space').

To enable indentation status please add the following to your initialization
file:

```lua
vim.g.linefly_options = {
  with_indent_status = true,
}
```

Sponsor
-------

[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/bluz71)

License
-------

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
