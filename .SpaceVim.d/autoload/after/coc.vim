  " install coc extensions
let s:coc_extensions = [
  \ 'coc-tabnine',
  \ 'coc-marketplace',
  \ 'coc-dictionary',
  \ 'coc-word',
  \ 'coc-json',
  \ 'coc-yaml',
  \ 'coc-tag',
  \ 'coc-sh',
  \ 'coc-vimlsp',
\]

let s:coc_preferences = {
  \ "autoTrigger": "always",
  \ "maxCompleteItemCount": 10,
  \ "codeLens.enable": 1,
  \ "diagnostic.virtualText": 1,
\}
function! after#coc#bootstrap() abort
  for extension in s:coc_extensions
    call SpaceVim#logger#info("installing [ " . extension . " ] coc extension")
    call coc#add_extension(extension)
  endfor
  call coc#config('coc.preferences', s:coc_preferences)
endfunction
