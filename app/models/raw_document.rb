# 取得した原文をそのままの形で持つ（docs/design.md「データの持ち方」）。jobs はここから再抽出できる
class RawDocument < ApplicationRecord
  has_one :job, dependent: :destroy
end
