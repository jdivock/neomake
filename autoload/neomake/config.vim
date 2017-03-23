let s:undef = {}

function! neomake#config#get_setting(name, default, ...) abort
  let context = a:0 ? a:1 : {}
  let ft = has_key(context, 'ft') ? context.ft : &filetype
  let bufnr = has_key(context, 'bufnr') ? +context.bufnr : bufnr('%')

  for prefix in ['ft:'.ft, '']
    " Log 'prefix: '.prefix
    for lookup in [getbufvar(bufnr, 'neomake'), get(g:, 'neomake', {}), get(context, 'maker', {})]
      " Log 'lookup: '.string(lookup)
      if empty(lookup)
        continue
      endif
      if len(prefix)
        let config = get(lookup, prefix, {})
      else
        let config = lookup
      endif
      if empty(config)
        continue
      endif
      let r = get(config, a:name, s:undef)
      if r isnot# s:undef
        " Log 'return: '.string(r)
        return r
      endif
    endfor
  endfor
  " Log 'default: '.string(a:default)
  return a:default
endfunction
