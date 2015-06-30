class Wechat::WcFrontController < ApplicationController
	before_action :check_openid,:except=>[:choose_technician,:technician_info]
	def choose_technician
		if params[:first]
			cookies[:openid]=params[:openid]
		end
		#sangna_config=SangnaConfig.includes(:per_user).find(params[:appid])
		#@technicians=sangna_config.per_user
		 @technicians=PerUserMasseuse.where(user_id:params[:user_id])
	end
	
	def technician_info
		@technician=PerUserMasseuse.find(params[:t_id])
	end

	def project_info
			sangna_config=SangnaConfig.includes(:per_user).find(params[:appid])
			@projects=PerUserProject.where(user_id:sangna_config.per_user.id)
	end

	def project_detail
			@project=PerUserProject.find(params[:p_id])
	end

	def sangna_info
			sangna_config=SangnaConfig.includes(:per_user).find(params[:appid])
			@sangna=sangna_config.per_user
			if @sangna.state==1&&@sangna.del==1
				@sangna_info=PerUserInfo.where(user_id:@sangna.id).first
			else
				render plain: "该会所暂时无法查看"
			end
	end

	def my_account
				wechat_config=WechatConfig.includes(:wechat_user).find_by_openid(cookies[:openid]) 
				@wechat_user=wechat_config.wechat_user
	end

	def my_collect
				sangna_config=SangnaConfig.includes(:per_user).find(params[:appid])
				wechat_config=WechatConfig.includes(:member).find_by_openid(cookies[:openid])
				technician_ids=sangna_config.per_user.masseuses_collects.where(member_id:wechat_config.member.id).pluck(:per_user_masseuse_id)
				@technicians=PerUserMasseuse.find(technician_ids)
	end


	private
	
	def check_openid
				if !cookies[:openid]							
					cookies[:next_url]=request.fullpath
					auth_url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{params[:appid]}&redirect_uri=http://weixin.linkke.cn/wechat/gzh_manage/oauth&response_type=code&scope=snsapi_base&state=123&component_appid=wxf6a05c0e64bc48e1#wechat_redirect"                    
		    redirect_to auth_url

				end
	end
end
