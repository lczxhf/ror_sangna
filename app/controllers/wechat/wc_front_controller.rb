class Wechat::WcFrontController < ApplicationController
	def choose_technician
		@technicians=PerUserMasseuse.where(user_id:params[:user_id])
	end
	
	def technician_info
		@technician=PerUserMasseuse.find(params[:t_id])
	end

	def project_info
			@projects=PerUserProject.where(user_id:params[:s_id])
	end

	def project_detail
			@project=PerUserProject.find(params[:p_id])
	end

	def sangna_info
			@sangna=PerUser.where(id:params[:s_id],del:1,status:1).first
			if @sangna
				@sangna_info=PerUserInfo.where(user_id:@sangna.id).first
			else
				render plain: "该会所暂时无法查看"
			end
	end

	def my_account
			 
	end

	def my_collect
	end
end
