Rails.application.routes.draw do
  resources :projects do
    resources :vacancies, only: [:index, :new]
  end
  
  get 'users/:user_id/candidatures', to: 'candidatures#index', as: 'user_candidatures'
  
  resources :vacancies do
    resources :candidatures, only: [:index, :new]
    resources :comments, only: [:index, :new]
    
    collection do
      put :update_multiple
      get :autocomplete
    end
    
    member do
      put :recommend
      put :accept_recommendation
      put :deny_recommendation 
      put :close
      put :reopen
    end
  end
  
  resources :candidatures do
    resources :comments, only: [:index, :new]
    
    collection do
      put :update_multiple
      get :autocomplete
    end
    
    member do
      get :accept
      get :deny
      get :quit
    end
  end
  
  namespace 'workflow' do
    resources :vacancies, controller: 'vacancies', only: :index do
      collection do
        get '/' => 'vacancies#open', as: :open
        
        get :autocomplete
        
        get :open
        get :recommended
        get :denied
        get :closed
      end
    end
    
    resources :candidatures, controller: 'candidatures', only: :index do
      collection do
        get '/' => 'candidatures#new', as: :new
         
        get :autocomplete 
         
        get :new
        get :accepted
        get :denied
      end
    end
  end
end
