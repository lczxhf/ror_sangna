Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
   
  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  namespace :wechat do
    get "third_party/test" => "third_party#test" 
		get "third_party/home" => "third_party#home"
		post "third_party/receive" => "third_party#receive"
		post "third_party/auth_code" => "third_party#auth_code"
		get "third_party/gzh_paramter" => "third_party#gzh_paramter"
	  get  "third_party/gzh_info" => "third_party#gzh_info"
	  get  "third_party/option_info" => "third_party#option_info"
		get "third_party/set_industry" => "third_party#set_industry"
		get "gzh_manage/set_menu" => "gzh_manage#set_menu"
		post "gzh_manage/authorize" => "gzh_manage#authorize"
		get "gzh_manage/get_info" => "gzh_manage#get_info"

    #match "/:name/:controller/:action",:via=>[:get]
  end

	namespace :tech do 
		get 'register' => 'register#register'
		get 'verify' => 'register#verify'
	end

	namespace :staff do 
		get 'signup' => 'per_user_staffs#new'

	end
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
