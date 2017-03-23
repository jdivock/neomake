let s:undef = {}

function! neomake#config#get_setting(name, default, ...) abort
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
