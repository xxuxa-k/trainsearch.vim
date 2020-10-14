let s:tokyo_metro_railway_dict = {
      \ 'Ginza': '銀座線',
      \ 'Tozai': '東西線',
      \ 'Namboku': '南北線',
      \ 'Hanzomon': '半蔵門線',
      \ 'Marunouchi': '丸ノ内線',
      \ 'Chiyoda': '千代田線',
      \ 'Fukutoshin': '副都心線',
      \ 'Yurakucho': '有楽町線',
      \ 'Hibiya': '日比谷線',
      \ }

function! s:tokyo_metro_api_url_with_consumery_key() abort
  return g:trainsearch_tokyo_metro_api_base_url . '?acl:consumerKey=' . g:trainsearch_tokyo_metro_api_consumer_key
endfunction

function! s:get_request_from_url(url) abort
  let response = webapi#http#get(a:url)
  let content = webapi#json#decode(response.content)
  return content
endfunction

function! s:tokyo_metro_api_full_url_with_params(params) abort
  let url = s:tokyo_metro_api_url_with_consumery_key()
  if keys(a:params) == []
    return url
  endif
  for key in keys(a:params)
    let url = url . '&' . key . '=' . a:params[key]
  endfor
  return url
endfunction

function! s:consumer_key_check() abort
  if g:trainsearch_tokyo_metro_api_consumer_key == ''
    return v:false
  endif
endfunction

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

function! trainsearch#train_info(name) abort
  let railway_name = get(s:tokyo_metro_railway_dict, a:name, '')
  if a:name == ''
    call echo_err('路線名を指定してください')
    return
  elseif railway_name == ''
    call echo_err('路線名が正しくありません')
    echo 
    return
  endif
  let odpt_railway_prefix = 'odpt.Railway:TokyoMetro.'
  let url = s:tokyo_metro_api_full_url_with_params({
        \ 'rdf:type': 'odpt:TrainInformation',
        \ 'odpt:railway': odpt_railway_prefix . a:name,
        \ })
  let content = s:get_request_from_url(url)
  if content == []
    call echo_err('結果が取得できませんでした')
    return
  endif
  let info = content[0]
  echo l:railway_name . ' => ' . info['odpt:trainInformationText']
endfunction

function! trainsearch#all_train_info() abort
  let url = s:tokyo_metro_api_full_url_with_params({
        \ 'rdf:type': 'odpt:TrainInformation',
        \ })
  let content = s:get_request_from_url(url)
  if content == []
    call echo_err('結果が取得できませんでした')
    return
  endif

  let i = 0
  while i < len(content)
    let info = content[i]
    let railway_code = substitute(info['odpt:railway'], 'odpt.Railway:TokyoMetro.', '', '')
    let railway_name = get(s:tokyo_metro_railway_dict, railway_code, '')
    echo railway_name . ' => ' . info['odpt:trainInformationText']
    let i = i + 1
  endwhile
endfunction
