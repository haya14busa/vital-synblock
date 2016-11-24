"=============================================================================
" FILE: autoload/vital/__vital__/Vim/Synblock.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================

function! s:synblock(lnum, col, synname) abort
  let stacks = s:synnamestack(a:lnum, a:col)
  let nest = s:find_last_index(stacks, a:synname)
  if nest ==# -1
    return {}
  endif
  return {
  \   'start': s:find_start(a:lnum, a:col, a:synname, nest),
  \   'end': s:find_end(a:lnum, a:col, a:synname, nest),
  \ }
endfunction

function! s:synnamestack(lnum, col) abort
  return map(synstack(a:lnum, a:col), {_, id -> synIDattr(id, 'name')})
endfunction

function! s:find_start(lnum, col, synname, nest) abort
  let lnum = a:lnum
  let col = a:col
  while v:true
    let prevlnum = lnum
    let prevcol = col
    if col > 1
      let col -= 1
    else
      let lnum -= 1 
      if lnum < 1
        return [1, 1]
      endif
      let col = len(getline(lnum))
    endif
    let synname = get(s:synnamestack(lnum, col), a:nest, '')
    if synname !=# a:synname
      break
    endif
  endwhile
  return [prevlnum, prevcol]
endfunction

function! s:find_end(lnum, col, synname, nest) abort
  let lnum = a:lnum
  let col = a:col
  let maxcols = {}
  let lastline = line('$')
  while v:true
    let prevlnum = lnum
    let prevcol = col
    let maxcol = get(maxcols, lnum, -1)
    if maxcol ==# -1
      let maxcol = len(getline(lnum))
    endif
    if col !=# maxcol
      let col += 1
    else
      let lnum += 1
      if lnum > lastline
        break
      endif
      let col = 1
    endif
    let synname = get(s:synnamestack(lnum, col), a:nest, '')
    if synname !=# a:synname
      break
    endif
  endwhile
  return [prevlnum, prevcol]
endfunction

function! s:find_last_index(xs, x) abort
  for i in reverse(range(len(a:xs)))
    if a:xs[i] ==# a:x
      return i
    endif
  endfor
  return -1
endfunction

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
