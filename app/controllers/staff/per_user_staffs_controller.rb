class Staff::PerUserStaffsController < ApplicationController

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
			render @per_user_staff.save
    else
      render json: @per_user_staff.errors
    end
  end

  def update
    @per_user_staff = User.find(1)
    if @per_user_staff.update_attributes(user_params)
      render json: @per_user_staff
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
end
