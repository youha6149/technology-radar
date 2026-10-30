class Job < ApplicationRecord
  belongs_to :raw_document
  has_one :reaction, dependent: :destroy

  # まだ +1 / -1 を付けていない求人（スキップした求人も含む）
  scope :unreacted, -> { where.missing(:reaction) }
end
