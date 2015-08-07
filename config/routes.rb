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
		post 'third_party/authorize' => "third_party#authorize"
		get "gzh_manage/set_menu" => "gzh_manage#set_menu"
		get "gzh_manage/authorize" => "gzh_manage#authorize"
		get "gzh_manage/oauth" =>"gzh_manage#oauth"
		get "gzh_manage/get_info" => "gzh_manage#get_info"
		get "gzh_manage/change_qrcode" =>"gzh_manage#change_qrcode"
		get "gzh_manage/sent_custom_message" => "gzh_manage#sent_custom_message"
		post "gzh_manage/sent_consumption_message" => "gzh_manage#sent_consumption_message"
    post 'message/:appid' => "message#receive"
    post 'wcpay/get_order' => "wcpay#get_order"
    post 'wcpay/callback' => "wcpay#callback"
    post 'wcpay/qr_pay' => "wcpay#qr_pay"
    post 'wcpay/redbage' => "wcpay#redbage"
    post 'wcpay/qrcallback' => "wcpay#qrcallback"
    post 'wcpay/qrresult' => "wcpay#qrresult"

    get "wc_front/choose_technician" => "wc_front#choose_technician"
		get "wc_front/technician_info" => "wc_front#technician_info"
		get 'wc_front/page_technician' => "wc_front$technician_info"
		get "wc_front/technician_remark" => "wc_front#technician_remark"
		get "wc_front/project_info" => "wc_front#project_info"
		get "wc_front/project_detail" => "wc_front#project_detail"
		get "wc_front/sangna_info" => "wc_front#sangna_info"
		get "wc_front/my_account" => "wc_front#my_account"
		get "wc_front/my_collect" => "wc_front#my_collect"
		get "wc_front/change_collect" =>"wc_front#change_collect"
		get "wc_front/redbage" =>"wc_front#redbage"
		post "wc_front/remark" => "wc_front#remark"
		post "wc_front/get_redbage" => "wc_front#get_redbage"
		get "wc_front/balance" => "wc_front#balance"
		get "wc_front/card_info" => "wc_front#card_info"
		get "wc_front/phone_bind" => "wc_front#phone_bind"
		post "wc_front/sent_code" => "wc_front#sent_code"
		post "wc_front/bind_phone" => "wc_front#bind_phone"
		get "wc_front/search" => "wc_front#search"
		post 'wc_front/use_card' => "wc_front#use_card"
    get 'wc_front/tip' => 'wc_front#tip'
		get "wc_front/project_class" => "wc_front#project_class"
    #match "/:name/:controller/:action",:via=>[:get]
  end

  namespace :tech do
    post 'register'         => 'register#register' #注册
    post 'verify'           => 'register#verify'  #验证码
    get 'project'           => 'register#project' #获取项目
    get 'upload'            => 'register#upload' #完善用户资料
    post 'login'            => 'register#login' #登陆


    get 'job'               => 'manage#project' #技师所属项目
    get 'job_number'        => 'manage#job_number' #技师工号
    get 'appointment'       => 'manage#appointment' #上报预约
    get 'projecttime'       => 'manage#gettime' #项目时长
    get 'details'           => 'manage#details' #个人详细资料
		get 'modifyname'        => 'manage#modifyname' #修改技师姓名
    get 'modifynumber'      => 'manage#modifynumber' #修改技师工种
    get 'findpwd'           => 'manage#findpwd' #技师找回密码之验证码
    get 'modifypwd'         => 'manage#modifypwd' #找回密码提交验证码
    post 'ensurepwd'        => 'manage#ensurepwd' #修改密码
    get 'modifysex'         => 'manage#modifysex' #技师修改性别
    get 'orderup'           => 'manage#orderup' #订单上钟
    get 'orderdown'         => 'manage#orderdown' #订单下钟
    get 'modifyident'       => 'manage#modifyident' #技师修改身份证
    get 'modifysex'         => 'manage#modifysex' #技师修改性别
    get 'modifyentry'       => 'manage#modifyentry' #技师修改入职时间
    get 'modifycraft'       => 'manage#modifycraft' #技师修改工种
    get 'modifylanguage'    => 'manage#modifylanguage' #技师修改语言
    get 'modifyproject'     => 'manage#modifyproject' #技师修改项目
    post 'changepwd'        => 'manage#changepwd' #技师修改密码
    get 'getaddress'        => 'manage#getaddress' #技师修改三级联动
    get 'nativeplace'       => 'manage#nativeplace' #获取技师籍贯
    get 'modifynativaplace' => 'manage#modifynativaplace' #修改技师籍贯
    get 'modifyaddress'     => 'manage#modifyaddress' #修改技师地址
    get 'jobstatus'         => 'manage#jobstatus' #获取技师状态
    get 'modifystatus'      => 'manage#modifystatus' #改变技师状态
    get 'work_time'         => 'manage#work_time' #技师工作时间
    get 'get_craft'         => 'manage#get_craft' #获取工种
    get 'get_pro'           => 'manage#get_pro' #获取该工种的项目
    get 'get_tech_craft'    => 'manage#get_tech_craft' #获取技师所属工种
    get 'subscribe'         => 'manage#subscribe' #获取预约清单
    get 'subscribe_de'      => 'manage#subscribe_de' #删除预约
    get 'get_atwork_time'   => 'manage#get_atwork_time' #获取上班时间
    get 'get_atwork_status' => 'manage#get_atwork_status' #更改上班状态      
    get 'update'            => 'update#update' #更新app
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
  # Example of regular route:pa
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
