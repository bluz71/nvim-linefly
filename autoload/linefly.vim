" Cache current statusline background for performance reasons; that being to
" avoid needless highlight extraction and generation.
let s:statusline_bg = ''

"===========================================================
" Utilities
"===========================================================

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
            " if g:lineflyWinBar && exists('&winbar') && winheight(0) > 1
            "     call setwinvar(winnum, '&winbar', '%!linefly#InactiveWinBar()')
            " endif
        endif
    endfor
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
