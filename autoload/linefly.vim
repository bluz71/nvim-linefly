let s:modes = {
  \  'n':      ['%#lineflyNormal#', ' normal ', '%#lineflyNormalEmphasis#'],
  \  'i':      ['%#lineflyInsert#', ' insert ', '%#lineflyInsertEmphasis#'],
  \  'R':      ['%#lineflyReplace#', ' r-mode ', '%#lineflyReplaceEmphasis#'],
  \  'v':      ['%#lineflyVisual#', ' visual ', '%#lineflyVisualEmphasis#'],
  \  'V':      ['%#lineflyVisual#', ' v-line ', '%#lineflyVisualEmphasis#'],
  \  "\<C-v>": ['%#lineflyVisual#', ' v-rect ', '%#lineflyVisualEmphasis#'],
  \  'c':      ['%#lineflyCommand#', ' c-mode ', '%#lineflyCommandEmphasis#'],
  \  's':      ['%#lineflyVisual#', ' select ', '%#lineflyVisualEmphasis#'],
  \  'S':      ['%#lineflyVisual#', ' s-line ', '%#lineflyVisualEmphasis#'],
  \  "\<C-s>": ['%#lineflyVisual#', ' s-rect ', '%#lineflyVisualEmphasis#'],
  \  't':      ['%#lineflyInsert#', ' t-mode ', '%#lineflyInsertEmphasis#'],
  \}

" Cache current statusline background for performance reasons; that being to
" avoid needless highlight extraction and generation.
let s:statusline_bg = ''

"===========================================================
" Utilities
"===========================================================

function! linefly#File() abort
    return s:FileIcon() . s:FilePath()
endfunction

function! s:FileIcon() abort
    if !g:lineflyWithFileIcon || bufname('%') == ''
        return ''
    endif

    if exists('g:nvim_web_devicons')
        return luaeval("require'nvim-web-devicons'.get_icon(vim.fn.expand('%'), nil, { default = true })") . ' '
    elseif exists('g:loaded_webdevicons')
        return WebDevIconsGetFileTypeSymbol() . ' '
    else
        return ''
    endif
endfunction

function! s:FilePath() abort
    if &buftype ==# 'terminal'
        return expand('%:t')
    else
        if len(expand('%:f')) == 0
            return ''
        else
            let l:separator = '/'
            if has('win32') || has('win64')
                let l:separator = '\'
            endif
            if &laststatus == 3
                let l:path = fnamemodify(expand('%:f'), ':~:.')
            else
                let l:path = pathshorten(fnamemodify(expand('%:f'), ':~:.'))
            endif
            let l:pathComponents = split(l:path, l:separator)
            let l:numPathComponents = len(l:pathComponents)
            if l:numPathComponents > 4
                return '.../' . join(l:pathComponents[l:numPathComponents - 4:], l:separator)
            else
                return l:path
            endif
        endif
    endif
endfunction

" Iterate though the windows and update the statusline and winbar for all
" inactive windows.
"
" This is needed when starting Vim with multiple splits, for example 'vim -O
" file1 file2', otherwise all statuslines/winbars will be rendered as if they
" are active. Inactive statuslines/winbar are usually rendered via the WinLeave
" and BufLeave events, but those events are not triggered when starting Vim.
"
" Note - https://jip.dev/posts/a-simpler-vim-statusline/#inactive-statuslines
function! linefly#UpdateInactiveWindows() abort
    for winnum in range(1, winnr('$'))
        if winnum != winnr()
            call setwinvar(winnum, '&statusline', '%!linefly#InactiveStatusLine()')
            if g:lineflyWinBar && exists('&winbar') && winheight(0) > 1
                call setwinvar(winnum, '&winbar', '%!linefly#InactiveWinBar()')
            endif
        endif
    endfor
endfunction

function! linefly#GitBranch() abort
    if !g:lineflyWithGitBranch || bufname('%') == ''
        return ''
    endif

    let l:git_branch_name = ''
    if g:lineflyWithGitsignsStatus && has('nvim-0.5') && luaeval("pcall(require, 'gitsigns')")
        " Gitsigns is available, let's use it to get the branch name since it
        " will already be in memory.
        let l:git_branch_name = get(b:, 'gitsigns_head', '')
    else
        " Fallback to traditional filesystem-based branch name detection.
        let l:git_branch_name = s:GitBranchName()
    endif

    if len(l:git_branch_name) == 0
        return ''
    endif

    if g:lineflyAsciiShapes
        return ' ' . l:git_branch_name
    else
        return '  ' . l:git_branch_name
    endif
endfunction

function! linefly#PluginsStatus() abort
    let l:status = ''
    let l:added = 0
    let l:changed = 0
    let l:removed = 0
    let l:errors = 0
    let l:warnings = 0
    let l:information = 0
    let l:divider = g:lineflyAsciiShapes ? '| ' : '⎪ '

    if g:lineflyWithGitsignsStatus && has('nvim-0.5') && luaeval("pcall(require, 'gitsigns')")
        " Gitsigns status.
        let l:counts = get(b:, 'gitsigns_status_dict', {})
        let l:added = get(l:counts, 'added', 0)
        let l:changed = get(l:counts, 'changed', 0)
        let l:removed = get(l:counts, 'removed', 0)
    elseif g:lineflyWithGitGutterStatus && exists('g:loaded_gitgutter')
        " GitGutter status.
        let [l:added, l:changed, l:removed] = GitGutterGetHunkSummary()
    elseif g:lineflyWithSignifyStatus && exists('g:loaded_signify') && sy#buffer_is_active()
        " Signify status.
        let [l:added, l:changed, l:removed] = sy#repo#get_stats()
    endif

    " Git plugin status.
    if l:added > 0
        let l:status .= ' %#lineflyGitAdd#+' . l:added . '%*'
    endif
    if l:changed > 0
        let l:status .= ' %#lineflyGitChange#~' . l:changed . '%*'
    endif
    if l:removed > 0
        let l:status .= ' %#lineflyGitDelete#-' . l:removed . '%*'
    endif
    if len(l:status) > 0
        let l:status .= ' '
    endif

    if g:lineflyWithNvimDiagnosticStatus && exists('g:lspconfig')
        " Neovim Diagnostic status.
        if has('nvim-0.6')
            let l:errors = luaeval('#vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})')
            let l:warnings = luaeval('#vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})')
            let l:information = luaeval('#vim.diagnostic.get(0, {severity = vim.diagnostic.severity.INFO})')
        elseif has('nvim-0.5')
            let l:errors = luaeval('vim.lsp.diagnostic.get_count(0, [[Error]])')
            let l:warnings = luaeval('vim.lsp.diagnostic.get_count(0, [[Warning]])')
        endif
    elseif g:lineflyWithALEStatus && exists('g:loaded_ale')
        " ALE status.
        let l:counts = ale#statusline#Count(bufnr(''))
        if has_key(l:counts, 'error')
            let l:errors = l:counts['error']
        endif
        if has_key(l:counts, 'warning')
            let l:warnings = l:counts['warning']
        endif
        if has_key(l:counts, 'info')
            let l:information = l:counts['info']
        endif
    elseif g:lineflyWithCocStatus && exists('g:did_coc_loaded')
        " Coc status.
        let l:counts = get(b:, 'coc_diagnostic_info', {})
        if has_key(l:counts, 'error')
            let l:errors = l:counts['error']
        endif
        if has_key(l:counts, 'warning')
            let l:warnings = l:counts['warning']
        endif
        if has_key(l:counts, 'information')
            let l:information = l:counts['information']
        endif
    endif

    " Display errors and warnings from any of the previous diagnostic or linting
    " systems.
    if l:errors > 0
        let l:status .= ' %#lineflyDiagnosticError#' . g:lineflyErrorSymbol
        let l:status .= ' ' . l:errors . '%* '
    endif
    if l:warnings > 0
        let l:status .= ' %#lineflyDiagnosticWarning#' . g:lineflyWarningSymbol
        let l:status .= ' ' . l:warnings . '%* '
    endif
    if l:information > 0
        let l:status .= ' %#lineflyDiagnosticInformation#' . g:lineflyInformationSymbol
        let l:status .= ' ' . l:information . '%* '
    endif

    " Obsession plugin status.
    if exists('g:loaded_obsession')
        if g:lineflyAsciiShapes
            let l:obsession_status = ObsessionStatus('$', 'S')
        else
            let l:obsession_status = ObsessionStatus('●', '■')
        endif
        if len(l:obsession_status) > 0
            let l:status .= ' %#lineflySession#' . l:obsession_status . '%*'
        endif
    endif

    return l:status
endfunction

function! linefly#IndentStatus() abort
    if !&expandtab
        return 'Tab:' . &tabstop
    else
        let l:size = &shiftwidth
        if l:size == 0
            let l:size = &tabstop
        end
        return 'Spc:' . l:size
    endif
endfunction

"===========================================================
" Status-line
"===========================================================

function! linefly#ActiveStatusLine() abort
    let l:mode = mode()
    let l:divider = g:lineflyAsciiShapes ? '|' : '⎪'
    let l:arrow =  g:lineflyAsciiShapes ?  '' : '↓'
    let l:git_branch = linefly#GitBranch()
    let l:mode_emphasis = get(s:modes, l:mode, '%#lineflyNormalEmphasis#')[2]

    let l:statusline = get(s:modes, l:mode, '%#lineflyNormal#')[0]
    let l:statusline .= get(s:modes, l:mode, ' normal ')[1]
    let l:statusline .= '%* %<%{linefly#File()}'
    let l:statusline .= "%{&modified ? '+\ ' : ' \ \ '}"
    let l:statusline .= "%{&readonly ? 'RO\ ' : ''}"
    if len(l:git_branch) > 0
        let l:statusline .= '%*' . l:divider . l:mode_emphasis
        let l:statusline .= l:git_branch . '%* '
    endif
    let l:statusline .= linefly#PluginsStatus()
    let l:statusline .= '%*%=%l:%c %*' . l:divider
    let l:statusline .= '%* ' . l:mode_emphasis . '%L%* ' . l:arrow . '%P '
    if g:lineflyWithIndentStatus
        let l:statusline .= '%*' . l:divider
        let l:statusline .= '%* %{linefly#IndentStatus()} '
    endif

    return l:statusline
endfunction

function! linefly#InactiveStatusLine() abort
    let l:divider = g:lineflyAsciiShapes ? '|' : '⎪'
    let l:arrow =  g:lineflyAsciiShapes ? '' : '↓'

    let l:statusline = ' %*%<%{linefly#File()}'
    let l:statusline .= "%{&modified?'+\ ':' \ \ '}"
    let l:statusline .= "%{&readonly?'RO\ ':''}"
    let l:statusline .= '%*%=%l:%c ' . l:divider . ' %L ' . l:arrow . '%P '
    if g:lineflyWithIndentStatus
        let l:statusline .= l:divider . ' %{linefly#IndentStatus()} '
    endif

    return l:statusline
endfunction

function! linefly#NoFileStatusLine() abort
    return pathshorten(fnamemodify(getcwd(), ':~:.'))
endfunction

function! linefly#StatusLine(active) abort
    if &buftype ==# 'nofile' || &filetype ==# 'netrw'
        " Likely a file explorer or some other special type of buffer. Set a
        " blank statusline for these types of buffers.
        setlocal statusline=%!linefly#NoFileStatusLine()
        if g:lineflyWinBar && exists('&winbar')
            setlocal winbar=
        endif
    elseif &buftype ==# 'nowrite'
        " Don't set a custom status line for certain special windows.
        return
    elseif a:active == v:true
        setlocal statusline=%!linefly#ActiveStatusLine()
        if g:lineflyWinBar && exists('&winbar')
            " Pure Lua version which excludes floating windows and quickfix
            " list:
            "   local window_count = 0
            "   local windows = vim.api.nvim_tabpage_list_wins(0)

            "   for _, v in pairs(windows) do
            "       local cfg = vim.api.nvim_win_get_config(v)
            "       local ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(v), "filetype")

            "       if (cfg.relative == "" or cfg.external == false) and ft ~= "qf" then
            "           window_count = window_count + 1
            "       end
            "   end
            "   if window_count > 1
            if len(filter(nvim_tabpage_list_wins(0), {k,v->nvim_win_get_config(v).relative == ''})) > 1 && &buftype !=# 'terminal'
                setlocal winbar=%!linefly#ActiveWinBar()
            else
                setlocal winbar=
            endif
        endif
    elseif a:active == v:false
        setlocal statusline=%!linefly#InactiveStatusLine()
        if g:lineflyWinBar && exists('&winbar') && winheight(0) > 1
            " Please repeat the window-counting from the previous if-clause
            " here when converting to Lua.
            if len(filter(nvim_tabpage_list_wins(0), {k,v->nvim_win_get_config(v).relative == ''})) > 1
                setlocal winbar=%!linefly#InactiveWinBar()
            else
                setlocal winbar=
            endif
        endif
    endif
endfunction

"===========================================================
" Window-bar
"===========================================================

function! linefly#ActiveWinBar() abort
    let l:mode = mode()
    let l:winbar = get(s:modes, l:mode, '%#lineflyNormal#')[0]
    let l:winbar .= strpart(get(s:modes, l:mode, 'n')[1], 0, 2)
    let l:winbar .= ' %* %<%{linefly#File()}'
    let l:winbar .= "%{&modified ? '+\ ' : ' \ \ '}"
    let l:winbar .= "%{&readonly ? 'RO\ ' : ''}"
    let l:winbar .= '%#Normal#'

    return l:winbar
endfunction

function! linefly#InactiveWinBar() abort
    let l:winbar = ' %*%<%{linefly#File()}'
    let l:winbar .= "%{&modified?'+\ ':' \ \ '}"
    let l:winbar .= "%{&readonly?'RO\ ':''}"
    let l:winbar .= '%#NonText#'

    return l:winbar
endfunction

"===========================================================
" Tab-line
"===========================================================

function! linefly#ActiveTabLine() abort
    let l:symbol = g:lineflyAsciiShapes ? '*' : '▪'
    let l:tabline = ''
    let l:counter = 0

    for i in range(tabpagenr('$'))
        let l:counter = l:counter + 1
        if has('tablineat')
            let l:tabline .= '%' . l:counter . 'T'
        endif
        if tabpagenr() == counter
            let l:tabline .= '%#TablineSelSymbol#' . l:symbol
            let l:tabline .= '%#TablineSel# Tab:'
        else
            let l:tabline .= '%#TabLine#  Tab:'
        endif
        let l:tabline .= l:counter
        if has('tablineat')
            let l:tabline .= '%T'
        endif
        let l:tabline .= '  %#TabLineFill#'
    endfor

    return l:tabline
endfunction

function! linefly#TabLine() abort
    if g:lineflyTabLine
        set tabline=%!linefly#ActiveTabLine()
    endif
endfunction

"===========================================================
" Highlights
"===========================================================

function! linefly#GenerateHighlightGroups() abort
    if !exists('g:colors_name')
        return
    endif

    " Extract current StatusLine background color, we will likely need it.
    if synIDattr(synIDtrans(hlID('StatusLine')), 'reverse', 'gui') == 1
        " Need to handle reversed highlights, such as Gruvbox StatusLine.
        let s:statusline_bg = synIDattr(synIDtrans(hlID('StatusLine')), 'fg', 'gui')
    else
        " Most colorschemes fall through to here.
        let s:statusline_bg = synIDattr(synIDtrans(hlID('StatusLine')), 'bg', 'gui')
    endif

    " Mode highlights.
    call s:ColorSchemeModeHighlights()

    " Synthesize emphasis colors from the existing mode colors.
    call s:SynthesizeHighlight('lineflyNormalEmphasis', 'lineflyNormal', v:true)
    call s:SynthesizeHighlight('lineflyInsertEmphasis', 'lineflyInsert', v:true)
    call s:SynthesizeHighlight('lineflyVisualEmphasis', 'lineflyVisual', v:true)
    call s:SynthesizeHighlight('lineflyCommandEmphasis', 'lineflyCommand', v:true)
    call s:SynthesizeHighlight('lineflyReplaceEmphasis', 'lineflyReplace', v:true)

    " Synthesize plugin colors from relevant existing highlight groups.
    call s:ColorSchemeGitHighlights()
    call s:ColorSchemeDiagnosticHighlights()
    call s:SynthesizeHighlight('lineflySession', 'Error', v:false)

    if g:lineflyTabLine
        if !hlexists('TablineSelSymbol') || synIDattr(synIDtrans(hlID('TablineSelSymbol')), 'bg') == ''
            highlight! link TablineSelSymbol TablineSel
        endif
    endif
endfunction

function! s:ColorSchemeModeHighlights() abort
    if g:colors_name == 'moonfly' || g:colors_name == 'nightfly'
        " Do nothing since both colorschemes already set linefly mode colors.
        return
    elseif g:colors_name == 'catppuccin'
        call s:SynthesizeModeHighlight('lineflyNormal', 'Title', 'VertSplit')
        call s:SynthesizeModeHighlight('lineflyInsert', 'String', 'VertSplit')
        call s:SynthesizeModeHighlight('lineflyVisual', 'Statement', 'VertSplit')
        call s:SynthesizeModeHighlight('lineflyCommand', 'Constant', 'VertSplit')
        call s:SynthesizeModeHighlight('lineflyReplace', 'Conditional', 'VertSplit')
    elseif g:colors_name == 'edge' || g:colors_name == 'everforest' || g:colors_name == 'gruvbox-material' || g:colors_name == 'sonokai' || g:colors_name == 'tokyonight'
        highlight! link lineflyNormal MiniStatuslineModeNormal
        highlight! link lineflyInsert MiniStatuslineModeInsert
        highlight! link lineflyVisual MiniStatuslineModeVisual
        highlight! link lineflyCommand MiniStatuslineModeCommand
        highlight! link lineflyReplace MiniStatuslineModeReplace
    elseif g:colors_name == 'dracula'
        highlight! link lineflyNormal WildMenu
        highlight! link lineflyInsert Search
        call s:SynthesizeModeHighlight('lineflyVisual', 'String', 'WildMenu')
        highlight! link lineflyCommand WildMenu
        highlight! link lineflyReplace IncSearch
    elseif g:colors_name == 'gruvbox'
        call s:SynthesizeModeHighlight('lineflyNormal', 'GruvboxFg4', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('lineflyInsert', 'GruvboxBlue', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('lineflyVisual', 'GruvboxOrange', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('lineflyCommand', 'GruvboxGreen', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('lineflyReplace', 'GruvboxRed', 'GruvboxBg0')
    elseif g:colors_name == 'carbonfox' || g:colors_name == 'nightfox' || g:colors_name == 'nordfox' || g:colors_name == 'terafox'
        highlight! link lineflyNormal Todo
        highlight! link lineflyInsert MiniStatuslineModeInsert
        highlight! link lineflyVisual MiniStatuslineModeVisual
        highlight! link lineflyCommand MiniStatuslineModeCommand
        highlight! link lineflyReplace MiniStatuslineModeReplace
    else
        " Fallback for all other colorschemes.
        if !hlexists('lineflyNormal') || synIDattr(synIDtrans(hlID('lineflyNormal')), 'bg') == ''
            call s:SynthesizeModeHighlight('lineflyNormal', 'Directory', 'VertSplit')
        endif
        if !hlexists('lineflyInsert') || synIDattr(synIDtrans(hlID('lineflyInsert')), 'bg') == ''
            call s:SynthesizeModeHighlight('lineflyInsert', 'String', 'VertSplit')
        endif
        if !hlexists('lineflyVisual') || synIDattr(synIDtrans(hlID('lineflyVisual')), 'bg') == ''
            call s:SynthesizeModeHighlight('lineflyVisual', 'Statement', 'VertSplit')
        endif
        if !hlexists('lineflyCommand') || synIDattr(synIDtrans(hlID('lineflyCommand')), 'bg') == ''
            call s:SynthesizeModeHighlight('lineflyCommand', 'WarningMsg', 'VertSplit')
        endif
        if !hlexists('lineflyReplace') || synIDattr(synIDtrans(hlID('lineflyReplace')), 'bg') == ''
            call s:SynthesizeModeHighlight('lineflyReplace', 'Error', 'VertSplit')
        endif
    endif
endfunction

function s:ColorSchemeGitHighlights() abort
    if hlexists('GitSignsAdd')
        call s:SynthesizeHighlight('lineflyGitAdd', 'GitSignsAdd', v:false)
        call s:SynthesizeHighlight('lineflyGitChange', 'GitSignsChange', v:false)
        call s:SynthesizeHighlight('lineflyGitDelete', 'GitSignsDelete', v:false)
    elseif hlexists('GitGutterAdd')
        call s:SynthesizeHighlight('lineflyGitAdd', 'GitGutterAdd', v:false)
        call s:SynthesizeHighlight('lineflyGitChange', 'GitGutterChange', v:false)
        call s:SynthesizeHighlight('lineflyGitDelete', 'GitGutterDelete', v:false)
    elseif hlexists('SignifySignAdd')
        call s:SynthesizeHighlight('lineflyGitAdd', 'SignifySignAdd', v:false)
        call s:SynthesizeHighlight('lineflyGitChange', 'SignifySignChange', v:false)
        call s:SynthesizeHighlight('lineflyGitDelete', 'SignifySignDelete', v:false)
    elseif hlexists('diffAdded')
        call s:SynthesizeHighlight('lineflyGitAdd', 'diffAdded', v:false)
        call s:SynthesizeHighlight('lineflyGitChange', 'diffChanged', v:false)
        call s:SynthesizeHighlight('lineflyGitDelete', 'diffRemoved', v:false)
    else
        highlight! link lineflyGitAdd StatusLine
        highlight! link lineflyGitChange StatusLine
        highlight! link lineflyGitDelete StatusLine
    endif
endfunction

function s:ColorSchemeDiagnosticHighlights() abort
    if hlexists('DiagnosticError')
        call s:SynthesizeHighlight('lineflyDiagnosticError', 'DiagnosticError', v:false)
    elseif hlexists('ALEErrorSign')
        call s:SynthesizeHighlight('lineflyDiagnosticError', 'ALEErrorSign', v:false)
    elseif hlexists('CocErrorSign')
        call s:SynthesizeHighlight('lineflyDiagnosticError', 'CocErrorSign', v:false)
    else
        highlight! link lineflyDiagnosticError StatusLine
    endif
    if hlexists('DiagnosticWarn')
        call s:SynthesizeHighlight('lineflyDiagnosticWarning', 'DiagnosticWarn', v:false)
    elseif hlexists('ALEWarningSign')
        call s:SynthesizeHighlight('lineflyDiagnosticWarning', 'ALEWarningSign', v:false)
    elseif hlexists('CocWarningSign')
        call s:SynthesizeHighlight('lineflyDiagnosticWarning', 'CocWarningSign', v:false)
    else
        highlight! link lineflyDiagnosticWarning StatusLine
    endif
    if hlexists('DiagnosticInfo')
        call s:SynthesizeHighlight('lineflyDiagnosticInformation', 'DiagnosticInfo', v:false)
    elseif hlexists('ALEInfoSign')
        call s:SynthesizeHighlight('lineflyDiagnosticInformation', 'ALEInfoSign', v:false)
    elseif hlexists('CocInfoSign')
        call s:SynthesizeHighlight('lineflyDiagnosticInformation', 'CocInfoSign', v:false)
    else
        highlight! link lineflyDiagnosticInformation StatusLine
    endif
endfunction

function! s:SynthesizeModeHighlight(target, background, foreground) abort
    let l:mode_bg = synIDattr(synIDtrans(hlID(a:background)), 'fg', 'gui')
    let l:mode_fg = synIDattr(synIDtrans(hlID(a:foreground)), 'fg', 'gui')

    if len(l:mode_bg) > 0 && len(l:mode_fg) > 0
        exec 'highlight ' . a:target . ' guibg=' . l:mode_bg . ' guifg=' . l:mode_fg
    else
        " Fallback to statusline highlighting.
        exec 'highlight! link ' . a:target . ' StatusLine'
    endif
endfunction

function! s:SynthesizeHighlight(target, source, reverse) abort
    if a:reverse
        let l:source_fg = synIDattr(synIDtrans(hlID(a:source)), 'bg', 'gui')
    else
        let l:source_fg = synIDattr(synIDtrans(hlID(a:source)), 'fg', 'gui')
    endif

    if len(s:statusline_bg) > 0 && len(l:source_fg) > 0
        exec 'highlight ' . a:target . ' guibg=' . s:statusline_bg . ' guifg=' . l:source_fg
    else
        " Fallback to statusline highlighting.
        exec 'highlight! link ' . a:target . ' StatusLine'
    endif
endfunction

"===========================================================
" Git utilities
"===========================================================

" The following Git branch name functionality derives from:
"   https://github.com/itchyny/vim-gitbranch
"
" MIT Licensed Copyright (c) 2014-2017 itchyny
"
function! s:GitBranchName() abort
    if get(b:, 'gitbranch_pwd', '') !=# expand('%:p:h') || !has_key(b:, 'gitbranch_path')
        call s:GitDetect()
    endif

    if has_key(b:, 'gitbranch_path') && filereadable(b:gitbranch_path)
        let l:branchDetails = get(readfile(b:gitbranch_path), 0, '')
        if l:branchDetails =~# '^ref: '
            return substitute(l:branchDetails, '^ref: \%(refs/\%(heads/\|remotes/\|tags/\)\=\)\=', '', '')
        elseif l:branchDetails =~# '^\x\{20\}'
            return l:branchDetails[:6]
        endif
    endif

    return ''
endfunction

function! s:GitDetect() abort
    unlet! b:gitbranch_path
    let b:gitbranch_pwd = expand('%:p:h')
    let l:dir = s:GitDir(b:gitbranch_pwd)

    if l:dir !=# ''
        let l:path = l:dir . '/HEAD'
        if filereadable(l:path)
            let b:gitbranch_path = l:path
        endif
    endif
endfunction

function! s:GitDir(path) abort
    let l:path = a:path
    let l:prev = ''

    while l:path !=# prev
        let l:dir = path . '/.git'
        let l:type = getftype(l:dir)
        if l:type ==# 'dir' && isdirectory(l:dir . '/objects')
                    \ && isdirectory(l:dir . '/refs')
                    \ && getfsize(l:dir . '/HEAD') > 10
            " Looks like we found a '.git' directory.
            return l:dir
        elseif l:type ==# 'file'
            let l:reldir = get(readfile(l:dir), 0, '')
            if l:reldir =~# '^gitdir: '
                return simplify(l:path . '/' . l:reldir[8:])
            endif
        endif
        let l:prev = l:path
        " Go up a directory searching for a '.git' directory.
        let path = fnamemodify(l:path, ':h')
    endwhile

    return ''
endfunction
