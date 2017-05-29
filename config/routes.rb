Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Devise + ActiveAdmin
  #devise_for :admins, ActiveAdmin::Devise.config
  #devise_for :users, ActiveAdmin::Devise.config
  #ActiveAdmin.routes(self)

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  ActiveAdmin.routes(self)

  # API
  # /api/v1/
  mount API::Base => '/'

  # API routes

  # GET
  # all publications                        => publications
  # single publication details              => publications/:id
  # all issues of a publication             => publications/:id/issues
  # all years of a publication              => publications/:id/years
  # all the publications in a year,
  # grouped by month                        => publication/:publication_id/year/:year

  # all issues                              => issues/
  # single issue details                    => issues/:id
  # year of issues of a publication         => issues/:publication_id/year/:year
  # unique months of a publication          => issues/unique_months
  # all the publications in a year/month    => issues/:publication_id/year/:year/:month
  # all the publications in a year          => publication/:publication_id/year/:year

  # POST
  # upload an issue                         => issues/

  # Application
  root "viewer#index"

  get "/search", to: "viewer#search"
  get "/search_results", to: "viewer#search_results"

  get "/corrector", to: "corrector#index"
  post "/corrector", to: "corrector#create"
  get "/corrector/score", to: "corrector#score"
  get "/corrector/help", to: "corrector#help"
  get "/user/profile", to: "corrector#profile"

  get "/publication/:publication_id", to: "viewer#index"
  get "/publication/:publication_id/issue/:issue_id", to: "viewer#index"
  get "/publication/:publication_id/issue/:issue_id/page/:page_id", to: "viewer#index"
  get "/issue/:issue_id", to: "viewer#index"
  get "/issue/:issue_id/page/:page_id", to: "viewer#index"
  get "/:issue_id", to: "viewer#index"
  get "/:issue_id/:page_id", to: "viewer#index"

end
