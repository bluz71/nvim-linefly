let s:modes = {
  \  'n':      ['%#LineflyNormal#', ' normal ', '%#LineflyNormalEmphasis#'],
  \  'i':      ['%#LineflyInsert#', ' insert ', '%#LineflyInsertEmphasis#'],
  \  'R':      ['%#LineflyReplace#', ' r-mode ', '%#LineflyReplaceEmphasis#'],
  \  'v':      ['%#LineflyVisual#', ' visual ', '%#LineflyVisualEmphasis#'],
  \  'V':      ['%#LineflyVisual#', ' v-line ', '%#LineflyVisualEmphasis#'],
  \  "\<C-v>": ['%#LineflyVisual#', ' v-rect ', '%#LineflyVisualEmphasis#'],
  \  'c':      ['%#LineflyCommand#', ' c-mode ', '%#LineflyCommandEmphasis#'],
  \  's':      ['%#LineflyVisual#', ' select ', '%#LineflyVisualEmphasis#'],
  \  'S':      ['%#LineflyVisual#', ' s-line ', '%#LineflyVisualEmphasis#'],
  \  "\<C-s>": ['%#LineflyVisual#', ' s-rect ', '%#LineflyVisualEmphasis#'],
  \  't':      ['%#LineflyInsert#', ' t-mode ', '%#LineflyInsertEmphasis#'],
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
    endif

    " Git plugin status.
    if l:added > 0
        let l:status .= ' %#LineflyGitAdd#+' . l:added . '%*'
    endif
    if l:changed > 0
        let l:status .= ' %#LineflyGitChange#~' . l:changed . '%*'
    endif
    if l:removed > 0
        let l:status .= ' %#LineflyGitDelete#-' . l:removed . '%*'
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
    endif

    " Display errors and warnings from any of the previous diagnostic or linting
    " systems.
    if l:errors > 0
        let l:status .= ' %#LineflyDiagnosticError#' . g:lineflyErrorSymbol
        let l:status .= ' ' . l:errors . '%* '
    endif
    if l:warnings > 0
        let l:status .= ' %#LineflyDiagnosticWarning#' . g:lineflyWarningSymbol
        let l:status .= ' ' . l:warnings . '%* '
    endif
    if l:information > 0
        let l:status .= ' %#LineflyDiagnosticInformation#' . g:lineflyInformationSymbol
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
            let l:status .= ' %#LineflySession#' . l:obsession_status . '%*'
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
    call s:SynthesizeHighlight('LineflyNormalEmphasis', 'LineflyNormal', v:true)
    call s:SynthesizeHighlight('LineflyInsertEmphasis', 'LineflyInsert', v:true)
    call s:SynthesizeHighlight('LineflyVisualEmphasis', 'LineflyVisual', v:true)
    call s:SynthesizeHighlight('LineflyCommandEmphasis', 'LineflyCommand', v:true)
    call s:SynthesizeHighlight('LineflyReplaceEmphasis', 'LineflyReplace', v:true)

    " Synthesize plugin colors from relevant existing highlight groups.
    call s:ColorSchemeGitHighlights()
    call s:ColorSchemeDiagnosticHighlights()
    call s:SynthesizeHighlight('LineflySession', 'Error', v:false)

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
        call s:SynthesizeModeHighlight('LineflyNormal', 'Title', 'VertSplit')
        call s:SynthesizeModeHighlight('LineflyInsert', 'String', 'VertSplit')
        call s:SynthesizeModeHighlight('LineflyVisual', 'Statement', 'VertSplit')
        call s:SynthesizeModeHighlight('LineflyCommand', 'Constant', 'VertSplit')
        call s:SynthesizeModeHighlight('LineflyReplace', 'Conditional', 'VertSplit')
    elseif g:colors_name == 'edge' || g:colors_name == 'everforest' || g:colors_name == 'gruvbox-material' || g:colors_name == 'sonokai' || g:colors_name == 'tokyonight'
        highlight! link LineflyNormal MiniStatuslineModeNormal
        highlight! link LineflyInsert MiniStatuslineModeInsert
        highlight! link LineflyVisual MiniStatuslineModeVisual
        highlight! link LineflyCommand MiniStatuslineModeCommand
        highlight! link LineflyReplace MiniStatuslineModeReplace
    elseif g:colors_name == 'dracula'
        highlight! link LineflyNormal WildMenu
        highlight! link LineflyInsert Search
        call s:SynthesizeModeHighlight('LineflyVisual', 'String', 'WildMenu')
        highlight! link LineflyCommand WildMenu
        highlight! link LineflyReplace IncSearch
    elseif g:colors_name == 'gruvbox'
        call s:SynthesizeModeHighlight('LineflyNormal', 'GruvboxFg4', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('LineflyInsert', 'GruvboxBlue', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('LineflyVisual', 'GruvboxOrange', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('LineflyCommand', 'GruvboxGreen', 'GruvboxBg0')
        call s:SynthesizeModeHighlight('LineflyReplace', 'GruvboxRed', 'GruvboxBg0')
    elseif g:colors_name == 'carbonfox' || g:colors_name == 'nightfox' || g:colors_name == 'nordfox' || g:colors_name == 'terafox'
        highlight! link LineflyNormal Todo
        highlight! link LineflyInsert MiniStatuslineModeInsert
        highlight! link LineflyVisual MiniStatuslineModeVisual
        highlight! link LineflyCommand MiniStatuslineModeCommand
        highlight! link LineflyReplace MiniStatuslineModeReplace
    else
        " Fallback for all other colorschemes.
        if !hlexists('LineflyNormal') || synIDattr(synIDtrans(hlID('LineflyNormal')), 'bg') == ''
            call s:SynthesizeModeHighlight('LineflyNormal', 'Directory', 'VertSplit')
        endif
        if !hlexists('LineflyInsert') || synIDattr(synIDtrans(hlID('LineflyInsert')), 'bg') == ''
            call s:SynthesizeModeHighlight('LIneflyInsert', 'String', 'VertSplit')
        endif
        if !hlexists('LineflyVisual') || synIDattr(synIDtrans(hlID('LineflyVisual')), 'bg') == ''
            call s:SynthesizeModeHighlight('LineflyVisual', 'Statement', 'VertSplit')
        endif
        if !hlexists('LineflyCommand') || synIDattr(synIDtrans(hlID('LineflyCommand')), 'bg') == ''
            call s:SynthesizeModeHighlight('LineflyCommand', 'WarningMsg', 'VertSplit')
        endif
        if !hlexists('LineflyReplace') || synIDattr(synIDtrans(hlID('LineflyReplace')), 'bg') == ''
            call s:SynthesizeModeHighlight('LineflyReplace', 'Error', 'VertSplit')
        endif
    endif
endfunction

function s:ColorSchemeGitHighlights() abort
    if hlexists('GitSignsAdd')
        call s:SynthesizeHighlight('LineflyGitAdd', 'GitSignsAdd', v:false)
        call s:SynthesizeHighlight('LineflyGitChange', 'GitSignsChange', v:false)
        call s:SynthesizeHighlight('LineflyGitDelete', 'GitSignsDelete', v:false)
    elseif hlexists('diffAdded')
        call s:SynthesizeHighlight('LineflyGitAdd', 'diffAdded', v:false)
        call s:SynthesizeHighlight('LineflyGitChange', 'diffChanged', v:false)
        call s:SynthesizeHighlight('LineflyGitDelete', 'diffRemoved', v:false)
    else
        highlight! link LineflyGitAdd StatusLine
        highlight! link LineflyGitChange StatusLine
        highlight! link LineflyGitDelete StatusLine
    endif
endfunction

function s:ColorSchemeDiagnosticHighlights() abort
    if hlexists('DiagnosticError')
        call s:SynthesizeHighlight('LineflyDiagnosticError', 'DiagnosticError', v:false)
    else
        highlight! link LineflyDiagnosticError StatusLine
    endif
    if hlexists('DiagnosticWarn')
        call s:SynthesizeHighlight('LineflyDiagnosticWarning', 'DiagnosticWarn', v:false)
    else
        highlight! link LineflyDiagnosticWarning StatusLine
    endif
    if hlexists('DiagnosticInfo')
        call s:SynthesizeHighlight('LineflyDiagnosticInformation', 'DiagnosticInfo', v:false)
    else
        highlight! link LineflyDiagnosticInformation StatusLine
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
" MIT Licensed Copyright (c) 2014-2021 itchyny
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
    let l:modules = a:path =~# '/\.git/modules/'

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
        elseif l:modules && isdirectory(a:path . '/objects') && isdirectory(a:path . '/refs') && getfsize(a:path . '/HEAD') > 10
            return a:path
        endif
        let l:prev = l:path
        " Go up a directory searching for a '.git' directory.
        let path = fnamemodify(l:path, ':h')
    endwhile

    return ''
endfunction
