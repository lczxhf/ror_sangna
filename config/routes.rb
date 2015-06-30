Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
   
  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  namespace :wechat do
    get "third_party/test" => "third_party#test" 
		get "third_party/test1" => "third_party#test1"
		get "third_party/home" => "third_party#home"
		post "third_party/receive" => "third_party#receive"
		get "third_party/auth_code" => "third_party#auth_code"
		get "third_party/gzh_paramter" => "third_party#gzh_paramter"
	  get  "third_party/gzh_info" => "third_party#gzh_info"
	  get  "third_party/option_info" => "third_party#option_info"
		get "third_party/set_industry" => "third_party#set_industry"
		get "gzh_manage/set_menu" => "gzh_manage#set_menu"
		post "gzh_manage/authorize" => "gzh_manage#authorize"
		post "gzh_manage/oauth" =>"gzh_manage#oauth"
		get "gzh_manage/get_info" => "gzh_manage#get_info"
    post 'message/:appid' => "message#receive"
    post 'wcpay/get_order' => "wcpay#get_order"
    post 'wcpay/callback' => "wcpay#callback"
    post 'wcpay/qr_pay' => "wcpay#qr_pay"
    post 'wcpay/redbage' => "wcpay#redbage"
    post 'wcpay/qrcallback' => "wcpay#qrcallback"
    post 'wcpay/qrresult' => "wcpay#qrresult"

    get "wc_front/choose_technician" => "wc_front#choose_technician"
		get "wc_front/technician_info" => "wc_front#technician_info"
		get "wc_front/project_info" => "wc_front#project_info"
		get "wc_front/project_detail" => "wc_front#project_detail"
		get "wc_front/sangna_info" => "wc_front#sangna_info"
		get "wc_front/my_account" => "wc_front#my_account"
		get "wc_front/my_collect" => "wc_front#my_collect"
    #match "/:name/:controller/:action",:via=>[:get]
  end
  
  namespace :tech do 
    post 'register' => 'register#register'
    post 'verify' => 'register#verify'
    get 'project' => 'register#project'
    post 'upload' => 'register#upload'
    get 'up' => 'register#up'
  end

	namespace :staff do 
		get    'per_user_staffs/all'    => 'per_user_staffs#index'
		get    'per_user_staffs/:id'    => 'per_user_staffs#show'
		get    'per_user_staffs/edit'   => 'per_user_staffs#edit'
		post   'per_user_staffs/create' => 'per_user_staffs#create'
		get    'sessions/login'         => 'sessions#new'
		post   'sessions/login'         => 'sessions#create'
		delete 'sessionslogout'         => 'sessions#destroy'
		get    'password_resets/new'    => 'password_resets#new'
		post   'password_resets/create' => 'password_resets#create'
		get    'password_resets/edit'   => 'password_resets#edit'
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
