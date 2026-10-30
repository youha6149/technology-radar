class ReactionsController < ApplicationController
  def create
    job = Job.find(params[:job_id])
    job.create_reaction!(verdict: params.require(:verdict))
    redirect_to root_path(after: job.id)
  end
end
