" A simple Vim / Neovim statusline.
"
" URL:          github.com/bluz71/vim-linefly-statusline
" License:      MIT (https://opensource.org/licenses/MIT)

if exists('g:loaded_linefly_statusline')
  finish
endif
let g:loaded_linefly_statusline = 1

" Please check that a true-color capable version of Vim or Neovim is currently
" running.
if has('nvim')
    if has('nvim-0.4') && len(nvim_list_uis()) > 0 && nvim_list_uis()[0]['ext_termcolors'] && !&termguicolors
        " The nvim_list_uis test indicates terminal Neovim vs GUI Neovim.
        " Note, versions prior to Neovim 0.4 did not set 'ext_termcolors'.
        echomsg 'The termguicolors option must be set'
        finish
    endif
else " Vim
    if !has('gui_running') && !exists('&termguicolors')
        echomsg 'A modern version of Vim with termguicolors is required'
        finish
    elseif !has('gui_running') && !&termguicolors
        echomsg 'The termguicolors option must be set'
        echomsg 'Be aware macOS default Vim is broken, use Homebrew Vim instead'
        finish
    endif
endif

" By default do not use Ascii character shapes for dividers and symbols.
let g:lineflyAsciiShapes = get(g:, 'lineflyAsciiShapes', v:false)

" The symbol used to indicate the presence of errors in the current buffer. By
" default the x character will be used.
let g:lineflyErrorSymbol = get(g:, 'lineflyErrorSymbol', 'x')

" The symbol used to indicate the presence of warnings in the current buffer. By
" default the exclamation symbol will be used.
let g:lineflyWarningSymbol = get(g:, 'lineflyWarningSymbol', '!')

" The symbol used to indicate the presence of information in the current buffer.
" By default the 'i' character will be used.
let g:lineflyInformationSymbol = get(g:, 'lineflyWarningSymbol', 'i')

" By default do not enable tabline support.
let g:lineflyTabLine = get(g:, 'lineflyTabLine', v:false)

" By default do not enable Neovim's winbar support.
let g:lineflyWinBar = get(g:, 'lineflyWinBar', v:false)

" By default do not display indentation details.
let g:lineflyWithIndentStatus = get(g:, 'lineflyWithIndentStatus', v:false)

" By default display Git branches.
let g:lineflyWithGitBranch = get(g:, 'lineflyWithGitBranch', v:true)

" By default display Gitsigns status, if the plugin is loaded.
let g:lineflyWithGitsignsStatus = get(g:, 'lineflyWithGitsignsStatus', v:true)

" By default display GitGutter status, if the plugin is loaded.
let g:lineflyWithGitGutterStatus = get(g:, 'lineflyWithGitGutterStatus', v:true)

" By default display Signify status, if the plugin is loaded.
let g:lineflyWithSignifyStatus = get(g:, 'lineflyWithSignifyStatus', v:true)

" By default don't display a filetype icon.
let g:lineflyWithFileIcon = get(g:, 'lineflyWithFileIcon', v:false)

" By default do indicate Neovim Diagnostic status, if nvim-lsp plugin is loaded.
let g:lineflyWithNvimDiagnosticStatus = get(g:, 'lineflyWithNvimDiagnosticStatus', v:true)

" By default do indicate ALE lint status, if the plugin is loaded.
let g:lineflyWithALEStatus = get(g:, 'lineflyWithALEStatus', v:true)

" By default do indicate Coc diagnostic status, if the plugin is loaded.
let g:lineflyWithCocStatus = get(g:, 'lineflyWithCocStatus', v:true)

augroup lineflyStatuslineEvents
    autocmd!
    autocmd VimEnter,ColorScheme * call linefly#GenerateHighlightGroups()
    autocmd VimEnter             * call linefly#UpdateInactiveWindows()
    autocmd VimEnter             * call linefly#TabLine()
    autocmd WinEnter,BufWinEnter * call linefly#StatusLine(v:true)
    autocmd WinLeave             * call linefly#StatusLine(v:false)
augroup END
