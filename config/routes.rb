Rails.application.routes.draw do
  root 'pages#home'

  # error pages
  %w( 403 404 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  get '/events/:event_id/locations', controller: :event_locations,
                                     action: :index, defaults: { format: :json }

  scope :countries, controller: :countries do
    get "/", action: :index
    get "/:country/subdivisions", action: :subdivisions
  end

  devise_for :admins, path: :game_control,
                      controllers: { invitations: "game_control/invitations" }

  namespace :game_control do
    root 'dashboard#index'

    get 'profile', to: 'profile#edit'
    patch 'profile', to: 'profile#update'
    patch 'profile/password', to: 'profile#update_password'

    resources 'cities'
    resources 'admins'
    resources 'events' do
      resources 'event_locations'
    end
    resources 'pages'
  end

  get '*slug', to: 'pages#show', constraints: { slug: /(?!game_control).*/ }
end
