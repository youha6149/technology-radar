class JobsController < ApplicationController
  # 未評価の求人を id 順に1件ずつ出す。after（直前に見た求人の id）より後ろがなければ先頭に戻る。
  # スキップは DB に何も書かず after を進めるだけなので、スキップした求人は一周するとまた出てくる
  def index
    after = params[:after].to_i
    @job = Job.unreacted.where("jobs.id > ?", after).order(:id).first || Job.unreacted.order(:id).first
    @remaining = Job.unreacted.count
  end

  def liked
    @jobs = Job.joins(:reaction).merge(Reaction.good).order("reactions.created_at DESC")
  end
end
