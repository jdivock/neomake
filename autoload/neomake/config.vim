let g:neomake#config#undefined = {}

" Resolve a:name (split on dots) and init a:dict accordingly.
function! s:resolve_name(dict, name) abort
  let c = a:dict
  let parts = split(a:name, '\.')
  for p in parts[0:-2]
    if !has_key(c, p)
      let c[p] = {}
    endif
    let c = c[p]
  endfor
  return [c, parts[-1]]
endfunction

" Get a:name (resolved; split on dots) from a:dict, using a:context.
function! s:get(dict, name, context) abort
  let ft = has_key(a:context, 'ft') ? a:context.ft : &filetype
  let parts = split(a:name, '\.')
  for prefix in ['ft.'.ft.'.', '']
    let [c, k] = s:resolve_name(a:dict, prefix.join(parts[0:-1], '.'))
    if has_key(c, k)
      return c[k]
    endif
  endfor
  return g:neomake#config#undefined
endfunction

" Get a:name from config.
" Optional args:
"  - a:1: default
"  - a:2: context
function! neomake#config#get(name, ...) abort
  let Default = a:0 ? a:1 : g:neomake#config#undefined
  let context = a:0 > 1 ? a:2 : {}
  if a:name =~# '^b:'
    if !has_key(context, 'bufnr')
      let context.bufnr = bufnr('%')
    endif
    let name = a:name[2:-1]
  else
    let name = a:name
  endif
  let bufnr = has_key(context, 'bufnr') ? context.bufnr : bufnr('%')

  for lookup in [
        \ getbufvar(bufnr, 'neomake'),
        \ get(g:, 'neomake', {}),
        \ get(context, 'maker', {})]
    if empty(lookup)
      continue
    endif
    let R = s:get(lookup, name, context)
    if R isnot# g:neomake#config#undefined
      return R
    endif
    unlet! lookup R  " old vim
  endfor
  return Default
endfunction

" Set a:name in a:dict to a:value, after resolving it (split on dots).
function! s:set(dict, name, value) abort
  let [c, k] = s:resolve_name(a:dict, a:name)
  let c[k] = a:value
  return c
endfunction

" Set a:name (resolved on dots) to a:value in the config.
function! neomake#config#set(name, value) abort
  if a:name =~# '^b:'
    return neomake#config#set_buffer(bufnr('%'), a:name[2:-1], a:value)
  endif
  if !has_key(g:, 'neomake')
    let g:neomake = {}
  endif
  return s:set(g:neomake, a:name, a:value)
endfunction

" Set a:name (resolved on dots) to a:value for buffer a:bufnr.
function! neomake#config#set_buffer(bufnr, name, value) abort
  let bufnr = +a:bufnr
  let bneomake = getbufvar(bufnr, 'neomake')
  if bneomake is# ''
    let bneomake = {}
    call setbufvar(bufnr, 'neomake', bneomake)
  endif
  return s:set(bneomake, a:name, a:value)
endfunction
