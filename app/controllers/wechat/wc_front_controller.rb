class Wechat::WcFrontController < ApplicationController
	def choose_jishi
		@technicians=PerUserMassscuses.where(user_id:params[:user_id])
	end
end
