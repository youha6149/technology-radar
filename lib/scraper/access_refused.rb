module Scraper
  # サイトにアクセスを拒否された（403 / 429）。呼び出す側は全体を中断する（拒否されたら回避しない）
  class AccessRefused < StandardError; end
end
