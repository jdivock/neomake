let s:undef = {}

function! neomake#config#get(name, default, ...) abort
  let context = a:0 ? a:1 : {}
  let ft = has_key(context, 'ft') ? context.ft : &filetype
  let bufnr = has_key(context, 'bufnr') ? +context.bufnr : bufnr('%')

  for prefix in ['ft:'.ft, '']
    for lookup in [getbufvar(bufnr, 'neomake'), get(g:, 'neomake', {}), get(context, 'maker', {})]
      if !empty(lookup)
        if len(prefix)
          let config = get(lookup, prefix, {})
        else
          let config = lookup
        endif
        if !empty(config)
          let r = get(config, a:name, s:undef)
          if r isnot# s:undef
            return r
          endif
        endif
      endif
      unlet! lookup  " old vim
    endfor
  endfor
  return a:default
endfunction

function! s:set(dict, name, value) abort
  let c = a:dict
  let parts = split(a:name, '\.')
  for p in parts[0:-2]
    if !has_key(c, p)
      let c[p] = {}
    endif
    let c = c[p]
  endfor
  let c[parts[-1]] = a:value
endfunction

function! neomake#config#set(name, value) abort
  if a:name =~# '^b:'
    return neomake#config#set_buffer(bufnr('%'), a:name[2:-1], a:value)
  endif
  if !has_key(g:, 'neomake')
    let g:neomake = {}
  endif
  return s:set(g:neomake, a:name, a:value)
endfunction

function! neomake#config#set_buffer(bufnr, name, value) abort
  let bufnr = +a:bufnr
  let bneomake = getbufvar(bufnr, 'neomake')
  if bneomake is# ''
    unlet bneomake  " old vim
    let bneomake = {}
    call setbufvar(bufnr, 'neomake', bneomake)
  endif
  return s:set(bneomake, a:name, a:value)
endfunction
