" Change the color scheme from a list of color scheme names.
" Version 2010-09-12 from http://vim.wikia.com/wiki/VimTip341
" Press key:
"   F8                next scheme
"   Shift-F8          previous scheme
"   Alt-F8            random scheme
" Set the list of color schemes used by the above (default is 'all'):
"   :SetColors all              (all $VIMRUNTIME/colors/*.vim)
"   :SetColors my               (names built into script)
"   :SetColors blue slate ron   (these schemes)
"   :SetColors                  (display current scheme names)
" Set the current color scheme based on time of day:
"   :SetColors now
if v:version < 700 || exists('loaded_setcolors') || &cp
  finish
endif

let loaded_setcolors = 1
let s:dark_colors = ['nightwish', 'darkblue', 'oceanblack', 'asu1dark', 'fnaqevan', 'torte', 'transparent', 'wintersday', 'murphy', 'wintersday', 'dusk', 'midnight2', 'neon', 'desert', 'darkblack', 'denim']
let s:light_colors = ['nuvola', 'jhlight', 'vc', 'biogoo', 'lingodirector', 'zellner', 'default', 'dawn', 'autumn', 'peachpuff']
let s:mycolors = s:dark_colors
let s:last_args = 'dark'

function! s:uniquify()
  let s:uniq = []
  for ic in s:mycolors
     if index(s:uniq, ic) == -1
        let s:uniq += [ic]
     endif
  endfor
  let s:mycolors = s:uniq
endfunction

function! SetColorFlipLight()
   let new = 'dark'
   if exists('s:last_args')
      if (s:last_args == 'dark')
         let new = 'light'
      endif
   endif
   call s:SetColors(new)
   call s:NextColor(1, 1)
endfunction

" Set list of color scheme names that we will use, except
" argument 'now' actually changes the current color scheme.
function! s:SetColors(args)
  if len(a:args) == 0
    echo 'Current color scheme names:'
    let i = 0
    while i < len(s:mycolors)
      echo '  '.join(map(s:mycolors[i : i+4], 'printf("%-14s", v:val)'))
      let i += 5
    endwhile
  elseif a:args == 'all'
    let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
    let s:mycolors = map(paths, 'fnamemodify(v:val, ":t:r")')
    echo 'List of colors set from all installed color schemes'
  elseif a:args == 'light'
    let s:mycolors = s:light_colors
    echo 'List of colors set from light bg schemes'
  elseif a:args == 'dark'
    let s:mycolors = s:dark_colors
    echo 'List of colors set from dark bg schemes'
  elseif a:args == 'now'
    call s:HourColor()
  else
    let s:mycolors = split(a:args)
    echo 'List of colors set from argument (space-separated names)'
  endif
  let s:last_args = a:args
  call s:uniquify()
endfunction

call s:uniquify() " in case we by mistake have a duplicate in pre-defined list 
command! -nargs=* SetColors call s:SetColors('<args>')

" Set next/previous/random (how = 1/-1/0) color from our list of colors.
" The 'random' index is actually set from the current time in seconds.
" Global (no 's:') so can easily call from command line.
function! NextColor(how)
  call s:NextColor(a:how, 1)
endfunction

" Helper function for NextColor(), allows echoing of the color name to be
" disabled.
function! s:NextColor(how, echo_color)
  if len(s:mycolors) == 0
    call s:SetColors('all')
  endif
  if exists('g:colors_name')
    let current = index(s:mycolors, g:colors_name)
  else
    let current = -1
  endif
  let missing = []
  let how = a:how
  for i in range(len(s:mycolors))
    if how == 0
      let current = localtime() % len(s:mycolors)
      let how = 1  " in case random color does not exist
    else
      let current += how
      if !(0 <= current && current < len(s:mycolors))
        let current = (how>0 ? 0 : len(s:mycolors)-1)
      endif
    endif
    try
      execute 'colorscheme '.s:mycolors[current]
      set background&
      break
    catch /E185:/
      call add(missing, s:mycolors[current])
    endtry
  endfor
  redraw
  if len(missing) > 0
    echo 'Error: colorscheme not found:' join(missing)
  endif
  if (a:echo_color)
    echo g:colors_name
  endif
endfunction

nnoremap <F8> :call NextColor(1)<CR>
nnoremap <S-F8> :call NextColor(-1)<CR>
nnoremap <A-F8> :call NextColor(0)<CR>
nnoremap <C-F8> :call SetColorFlipLight()<CR>

" Set color scheme according to current time of day.
function! s:HourColor()
  let hr = str2nr(strftime('%H'))
  if hr <= 3
    let i = 0
  elseif hr <= 7
    let i = 1
  elseif hr <= 14
    let i = 2
  elseif hr <= 18
    let i = 3
  else
    let i = 4
  endif
  let nowcolors = 'elflord morning desert evening pablo'
  execute 'colorscheme '.split(nowcolors)[i]
  redraw
  echo g:colors_name
endfunction
