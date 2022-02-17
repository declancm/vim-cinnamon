" KEYMAPS:

" <Cmd>Scroll arg1 arg2 arg3 arg4 arg5 <CR>

" arg1 = Movement command (eg. 'gg'). This argument is required as there's no default value.
" arg2 = Scroll the window (1 for on, 0 for off). Default is 1.
" arg3 = Accept a count before the command (1 for on, 0 for off). Default is 0.
" arg4 = Length of delay (in ms). Default is 5.
" arg5 = Slowdown at the end of the movement (1 for on, 0 for off). Default is 1.

if !exists("g:cinnamon_no_defaults")
    let g:cinnamon_no_defaults = 0
endif
if g:cinnamon_no_defaults != 1
    " paragraph movements
    nnoremap <silent> { <Cmd>Scroll { 0 <CR>
    nnoremap <silent> } <Cmd>Scroll } 0 <CR>
    xnoremap <silent> { k<Cmd>Scroll {j 0 <CR>
    xnoremap <silent> } j<Cmd>Scroll }k 0 <CR>

    " half-window movements
    nnoremap <silent> <C-u> <Cmd>Scroll <C-u> <CR>
    nnoremap <silent> <C-d> <Cmd>Scroll <C-d> <CR>
    inoremap <silent> <C-u> <Cmd>Scroll <C-u> <CR>
    inoremap <silent> <C-d> <Cmd>Scroll <C-d> <CR>

    " page movements
    nnoremap <silent> <C-b> <Cmd>Scroll <C-b> <CR>
    nnoremap <silent> <C-f> <Cmd>Scroll <C-f> <CR>
    inoremap <silent> <C-b> <Cmd>Scroll <C-b> <CR>
    inoremap <silent> <C-f> <Cmd>Scroll <C-f> <CR>
    nnoremap <silent> <PageUp> <Cmd>Scroll <C-b> <CR>
    nnoremap <silent> <PageDown> <Cmd>Scroll <C-f> <CR>
    inoremap <silent> <PageUp> <Cmd>Scroll <C-b> <CR>
    inoremap <silent> <PageDown> <Cmd>Scroll <C-f> <CR>
endif

if !exists("g:cinnamon_extra_defaults")
    let g:cinnamon_extras = 0
endif
if g:cinnamon_extras != 1
    " start and end of file
    nnoremap <silent> gg <Cmd>Scroll gg 0 0 1 <CR>
    nnoremap <silent> G <Cmd>Scroll G 0 0 1 <CR>
    xnoremap <silent> gg <Cmd>Scroll gg 0 0 1 <CR>
    xnoremap <silent> G <Cmd>Scroll G 0 0 1 <CR>

    " up and down movements
    nnoremap <silent> k <Cmd>Scroll k 0 1 2 0 <CR>
    nnoremap <silent> j <Cmd>Scroll j 0 1 2 0 <CR>
    nnoremap <silent> <Up> <Cmd>Scroll k 0 1 2 0 <CR>
    nnoremap <silent> <Down> <Cmd>Scroll j 0 1 2 0 <CR>
    xnoremap <silent> k <Cmd>Scroll k 0 1 2 0 <CR>
    xnoremap <silent> j <Cmd>Scroll j 0 1 2 0 <CR>
    xnoremap <silent> <Up> <Cmd>Scroll k 0 1 2 0 <CR>
    xnoremap <silent> <Down> <Cmd>Scroll j 0 1 2 0 <CR>
endif

" COMMANDS:

command! -nargs=+ Scroll call <SID>Scroll(<f-args>)

" FUNCTIONS:

function! s:Scroll(movement, scrollWin = '1', useCount = '0', delay = '5', slowdown = '1') abort
    let l:pos = getcurpos()[1]
    let l:distance = <SID>MovementDistance(a:movement, a:useCount)
    if l:distance == 0 | return | endif
    let l:counter = 1
    if distance > 0
        " scrolling downwards
        while l:counter <= l:distance
            silent execute("normal! j")
            if a:scrollWin == 1
                if ! (winline() <= &scrolloff + 1 || winline() >= winheight('%') - &scrolloff)
                    silent execute("normal! \<C-E>")
                endif
            endif
            let l:remaining = l:distance - l:counter
            call <SID>SleepDelay(l:remaining, a:delay, a:slowdown)
            let l:counter = <SID>CheckFoldCounter(l:counter)
        endwhile
    else
        " scrolling upwards
        while l:counter <= -l:distance
            silent execute("normal! k")
            if a:scrollWin == 1
                if ! (winline() <= &scrolloff + 1 || winline() >= winheight('%') - &scrolloff)
                    silent execute("normal! \<C-Y>")
                endif
            endif
            let l:remaining = -l:distance - l:counter
            call <SID>SleepDelay(l:remaining, a:delay, a:slowdown)
            let l:counter = <SID>CheckFoldCounter(l:counter)
        endwhile
    endif
endfunction

function! s:CheckFoldCounter(counter)
    let l:counter = a:counter
    let l:foldStart = foldclosed(".")
    if l:foldStart != -1
        let l:foldSize = foldclosedend(l:foldStart) - l:foldStart
        echom l:foldSize
        let l:counter += l:foldSize
    endif
    let l:counter += 1
    return l:counter
endfunction

function! s:MovementDistance(movement, useCount)
    let l:winview = winsaveview()
    let l:pos = getcurpos()[1]
    if a:useCount == 1
        silent execute("normal! " . v:count1 . a:movement)
    else
        silent execute("normal! " . a:movement)
    endif
    let l:newPos = getcurpos()[1]
    let l:distance = l:newPos - l:pos
    call winrestview(l:winview)
    return l:distance
endfunction

function! s:SleepDelay(remaining, delay, slowdown)
    if a:slowdown == 1
        if a:remaining <= 4
            silent execute("sleep " . (a:delay * (5 - a:remaining)) . "m")
        else
            silent execute("sleep " . a:delay . "m")
        endif
    else
        silent execute("sleep " . a:delay . "m")
    endif
    redraw
endfunction
