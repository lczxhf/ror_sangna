class Staff::PerUserStaffsController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
	before_action :correct_user,   only: [:edit, :update]
	# skip_before_action :verify_authenticity_token # 交互时忽略csrf
	include Staff::SessionsHelper
  def index
		# @peruserstaffs = PerUserStaff.all
		render json: PerUserStaff.all
  end

	def show
		# @per_user_staff = PerUserStaff.find(params[:id])
		render json: PerUserStaff.find(1)
	end

	def new
		#	@per_user_staff = PerUserStaff.new
		
	end

  def create
    @per_user_staff = PerUserStaff.new(user_params)
    if @per_user_staff.save
			log_in @per_user_staff
			render @per_user_staff.save
    else
      render json: @per_user_staff.errors
    end
  end

	def edit
		@per_use_staff = PerUserStaff.find(1)
	end

  def update
    @per_user_staff = User.find(1)
    if @per_user_staff.update_attributes(user_params)
      render json: @per_user_staff, status: '修改成功！' 
    else
      render json: @per_user_staff.errors
    end
  end

	def destroy
		@per_user_staff.destroy
		head :no_content
	end

	private

		def user_params
			params.require(:per_user_staff).permit(:username, :password,
																	 :password_confirmation)
		end

		# 事前过滤器
		# 确保用户已登录
    def logged_in_user
      unless logged_in?
        flash[:danger] = "请登录."
      end
    end
		# 确保是正确的用户
    def correct_user
      @per_user_staff = PerUserStaff.find(params[:id])
      # redirect_to(root_url) unless @user == current_user
    end
end
