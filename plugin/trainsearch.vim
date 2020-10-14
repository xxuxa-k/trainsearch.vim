if exists('g:loaded_trainsearch')
  finish
endif

let g:loaded_trainsearch = 1
let g:trainsearch_tokyo_metro_api_base_url = 'https://api.tokyometroapp.jp/api/v2/datapoints'

command! TrainsearchAllTrainInfo call trainsearch#all_train_info()
command! -nargs=1 TrainsearchSingleTrainInfo call trainsearch#train_info(<q-args>)
