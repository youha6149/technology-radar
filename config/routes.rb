Rails.application.routes.draw do
  # まだ評価していない求人を1件ずつカードで出す
  root "jobs#index"
  # +1 を付けた求人の一覧（ストーリーB）
  get "liked", to: "jobs#liked", as: :liked_jobs

  resources :jobs, only: [] do
    resource :reaction, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
