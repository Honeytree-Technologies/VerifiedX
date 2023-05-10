Rails.application.routes.draw do
  # See `config/routes/*.rb` to customize these configurations.
  draw "concerns"
  draw "devise"
  draw "sidekiq"

  # This is helpful to have around when working with shallow routes and complicated model namespacing. We don't use this
  # by default, but sometimes Super Scaffolding will generate routes that use this for `only` and `except` options.
  # TODO Would love to get this out of the application routes file.
  collection_actions = [:index, :new, :create] # standard:disable Lint/UselessAssignment

  # This helps mark `resources` definitions below as not actually defining the routes for a given resource, but just
  # making it possible for developers to extend definitions that are already defined by the `bullet_train` Ruby gem.
  # TODO Would love to get this out of the application routes file.
  extending = {only: []}

  scope module: "public" do
    # To keep things organized, we put non-authenticated controllers in the `Public::` namespace.
    # The root `/` path is routed to `Public::HomeController#index` by default.
    get 'accounts/show', to: 'accounts#show'
    post 'accounts/check', to: 'accounts#check'
    delete 'accounts/delete', to: 'accounts#delete', as: :request_remove
    post 'accounts/restore', to: 'accounts#cancel_delete', as: :restore_account
    get 'accounts/job_titles', to: 'accounts#job_titles'
    get ':account_type/new', to: 'accounts#new', as: :new_account, constraints: { account_type: /accounts|people|organizations/ }
    get ':account_type/:handle', to: 'accounts#show', as: :show_account, constraints: { handle: /[^\/]+/, account_type: /accounts|people|organizations/ }
    post 'accounts', to: 'accounts#create', as: :create_account
    post 'accounts/show_statuses', to: 'accounts#show_statuses'
    get 'profile', to: 'accounts#edit', as: :edit_account
    get 'topics', to: 'topics#index'
    get 'topics/:frame_id', to: 'topics#value'
    get 'regions', to: 'home#regions'
    get 'countries', to: 'home#countries'
    get 'privacy-policy', to: 'home#privacy'
    get 'terms-of-use', to: 'home#terms'
    get 'about', to: 'home#about'
    get 'faq', to: 'home#faq'
    get 'news', to: 'home#news'

    # authentication
    post 'login', to: 'sessions#login'
    delete 'logout', to: 'sessions#logout'
    get 'oauth/callback', to: 'sessions#callback'
    post 'request_confirm', to: 'sessions#request_confirm'
    get 'confirm_email', to: 'sessions#confirm_email', as: :confirm_email
  end

  # namespace :webhooks do
  #   namespace :incoming do
  #     resources :bullet_train_webhooks
  #     namespace :oauth do
  #       # 🚅 super scaffolding will insert new oauth provider webhooks above this line.
  #     end
  #   end
  # end

  namespace :api do
    draw "api/v1"
    # 🚅 super scaffolding will insert new api versions above this line.
  end

  namespace :account do
    shallow do
      # user-level onboarding tasks.
      # namespace :onboarding do
      #   # routes for standard onboarding steps are configured in the `bullet_train` gem, but you can add more here.
      # end

      match 'settings', to: 'dashboard#settings', via: [:get, :post]

      # user specific resources.
      resources :users, extending do
        # namespace :oauth do
        #   # 🚅 super scaffolding will insert new oauth providers above this line.
        # end

        # routes for standard user actions and resources are configured in the `bullet_train` gem, but you can add more here.
      end

      # team-level resources.
      resources :teams, extending do
        # routes for many teams actions and resources are configured in the `bullet_train` gem, but you can add more here.

        # add your resources here.

        # resources :invitations, extending do
        #   # routes for standard invitation actions and resources are configured in the `bullet_train` gem, but you can add more here.
        # end
        #
        # resources :memberships, extending do
        #   # routes for standard membership actions and resources are configured in the `bullet_train` gem, but you can add more here.
        # end
        #
        # namespace :integrations do
        #   # 🚅 super scaffolding will insert new integration installations above this line.
        # end

        resources :accounts

        resources :users

        resources :topics
      end
      authenticate :user do
        mount Sidekiq::Web => '/sidekiq'
      end
    end
  end
end
