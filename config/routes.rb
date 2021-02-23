require 'api_constraints'

Rails.application.routes.draw do
	namespace :api, defaults: { format: :json } do
		scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
    	post '/accounts', to: 'users#create'

			get '/me', to: 'users#show'
			post '/me/destroy', to: 'users#destroy'
			post '/me/update', to: 'users#update'

			resources :tokens, :only => [:create]

			get '/activities', to: 'activities#all'
    	resources :activities, :only => [:show, :create, :update, :destroy] do
				get '/reminders', to: 'reminders#all'
    		resources :reminders, :only => [:show, :create, :update, :destroy]
      end
    end
  end
end
