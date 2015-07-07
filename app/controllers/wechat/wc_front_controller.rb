class Wechat::WcFrontController < ApplicationController
	before_action :check_openid
	def choose_technician
		if params[:first]
			cookies.signed["#{params[:appid]}_openid"]=params[:openid]
		end
		#cookies.delete("#{params[:appid]}_openid")
		#cookies.delete(:next_url)
		@sangna_config=SangnaConfig.includes(:per_user).find_by_appid(params[:appid])
		@technicians=PerUserMasseuse.where(user_id:@sangna_config.per_user.id,)
		@inscene=false
		if wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])	
			 if wechat_config.member.hand_code	
						if PerUserQrCode.where(user_id:@sangna_config.per_user.id,hand_code:wechat_config.member.hand_code).first
								@inscene=true
						else
								cookies["next_url"]=request.url
						end
			 end
		end
		# @technicians=PerUserMasseuse.where(user_id:params[:user_id])
	end
	
	def technician_info
		@technician=PerUserMasseuse.find(params[:t_id])
	end

	def technician_remark
	end

	def project_info
			sangna_config=SangnaConfig.includes(:per_user).find_by_appid(params[:appid])
			@projects=PerUserProject.where(user_id:sangna_config.per_user.id)
	end

	def project_detail
			@project=PerUserProject.find(params[:p_id])
	end

	def sangna_info
			sangna_config=SangnaConfig.includes(:per_user).find_by_appid(params[:appid])
			@sangna=sangna_config.per_user
			if @sangna.status==1&&@sangna.del==1
				@per_user_imgs=@sangna.per_user_imgs
				@sangna_info=@sangna.per_user_info
			else
				render plain: "该会所暂时无法查看"
			end
	end

	def my_account
				wechat_config=WechatConfig.includes(:wechat_user).find_by_openid(cookies.signed["#{params[:appid]}_openid"]) 
				@wechat_user=wechat_config.wechat_user
	end

	def my_collect
				sangna_config=SangnaConfig.includes(:per_user).find_by_appid(params[:appid])
				wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				technician_ids=sangna_config.per_user.masseuses_collects.where(member_id:wechat_config.member.id,del:1).pluck(:per_user_masseuse_id)
				@technicians=PerUserMasseuse.find(technician_ids)
	end

	def change_collect
				puts params
				technician=PerUserMasseuse.find(params[:technician_id])
				wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				sangna_config=SangnaConfig.includes(:per_user).find_by_appid(params[:appid])
			  collect=MasseusesCollect.find_or_initialize_by(per_user_masseuse_id:technician.id,member_id:wechat_config.member.id,per_user_id:sangna_config.per_user.id)
				if params[:status]=="add"
						collect.del=1
				else
					  collect.del=2	
				end
				collect.save
				render plain: "success"	
	end

	private
	
	def check_openid
			if !cookies["#{params[:appid]}_openid"]							
			cookies.signed[:next_url]=request.url
			auth_url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{params[:appid]}&redirect_uri=http://weixin.linkke.cn/wechat/gzh_manage/oauth&response_type=code&scope=snsapi_base&state=123&component_appid=wxf6a05c0e64bc48e1#wechat_redirect"                    
		   redirect_to auth_url
			end
	end
end
