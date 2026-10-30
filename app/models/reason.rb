# 評価の理由（質問形式の回答）。良い理由か悪い理由かは reaction.verdict から導く
class Reason < ApplicationRecord
  belongs_to :reaction
end
