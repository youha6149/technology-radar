# 1つの求人に評価は1つ（job_id は unique）。0 は作らず、判断できなければ行を作らない（スキップ）
class Reaction < ApplicationRecord
  belongs_to :job
  has_many :reasons, dependent: :destroy

  enum :verdict, { good: 1, bad: -1 }
end
