class Staff::SessionsController < ApplicationController

	def new
	end

	def create
    @auth_user = PerUserStaff.find_by(username: params[:session][:username])
    if @auth_user && @auth_user.authenticate(params[:session][:password])
			log_in @auth_user
			render json: { status: '验证成功！' }
      # 登入用户，然后重定向到用户的资料页面
    else
      # 创建一个错误消息
      render json: { :errors => @auth_user.errors.full_messages }
    end
	end

	def destroy
		log_out
	end
	
end
