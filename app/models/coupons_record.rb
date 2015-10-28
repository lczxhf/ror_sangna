class CouponsRecord < ActiveRecord::Base
	belongs_to :coupons_rule,foreign_key: 'coupons_rules_id'
	belongs_to :order_by_masseuse,foreign_key: 'from_order_id'
	belongs_to :qrcode_log
	belongs_to :member
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :ab_recommended_project,class_name: 'UserAbProjectsCouponsRulesRecommendedProject',foreign_key: 'projects_id'
	belongs_to :coupons_class,foreign_key: 'coupons_classes_id'

	#发送微信模板消息!卡券核销通知
	def sent_message(sangna_config,wechat_config,card_ids)
			templete=TempleteNumber.find_by_topic('卡券核销通知')	
			message=templete.templete_messages.where(sangna_config_id:sangna_config.id).first

			hash={}
			hash["first"]="您有#{card_ids.size}张卡券刚被店家核销,为避免打扰您!只发送此次通知消息给您."
			hash["remark"]="点击详情可查看被使用的卡券\\n#{sangna_config.per_user.name}期待您再次的光临!"
			array=['代金券','点击查看',Time.now.strftime("%Y年%m月%d日 %H:%M")]
			templete.fields.split(',').each_with_index do |a,index|
				  hash[a]=array[index]
			end
			if Time.now-sangna_config.updated_at>=7200
					result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),"wxf6a05c0e64bc48e1",sangna_config.appid,sangna_config.refresh_token))
					if result['authorizer_refresh_token']
						sangna_config.refresh_token=result['authorizer_refresh_token']
						sangna_config.token=result['authorizer_access_token']
						sangna_config.save
					end
			end
			url="http://weixin.linkke.cn/wechat/wc_front/consumption_info?appid=#{sangna_config.appid}&card_ids=#{card_ids.join(',')}"
			Sangna.sent_template_message(sangna_config.token,wechat_config.openid,message.templete_id,url,hash)
	end

	def self.sent_due_message(sangna_config,num,openid)
		templete=TempleteNumber.find_by_topic('优惠券到期提醒') 
	  message=templete.templete_messages.where(sangna_config_id:sangna_config.id).first
		hash={}
		hash["first"]="您有#{num}张卡券即将过期!"
		hash["remark"]="#{sangna_config.per_user.name}期待您再次的光临!"
		array=['代金券','所有项目','点击查看']
		templete.fields.split(',').each_with_index do |a,index|
			hash[a]=array[index]
		end
		if Time.now-sangna_config.updated_at>=7200
			result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),"wxf6a05c0e64bc48e1",sangna_config.appid,sangna_config.refresh_token))
			if result['authorizer_refresh_token']
				sangna_config.refresh_token=result['authorizer_refresh_token']
				sangna_config.token=result['authorizer_access_token']
				sangna_config.save
			end
		end
		url="http://weixin.linkke.cn/wechat/wc_front/card_info?appid=#{sangna_config.appid}"
		Sangna.sent_template_message(sangna_config.token,openid,message.templete_id,url,hash)
		end

end
