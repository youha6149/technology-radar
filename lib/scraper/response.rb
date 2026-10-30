module Scraper
  # PoliteHttpClient#get の戻り値。本文はバイト列のまま（文字コードの解釈や gzip の展開は、取得元を知っている Fetcher が行う）
  Response = Data.define(:body, :content_type)
end
