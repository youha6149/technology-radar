module Scraper
  # リクエストが失敗した（200 以外、タイムアウト、接続できない など）。呼び出す側はその1件を飛ばして続ける。
  # AccessRefused とは呼び出す側の扱いが違うので、継承関係にしない（rescue RequestFailed で拒否まで拾わないように）
  class RequestFailed < StandardError; end
end
