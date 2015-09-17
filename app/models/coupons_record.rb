class CouponsRecord < ActiveRecord::Base
	belongs_to :coupons_rule,foreign_key: 'coupons_rules_id'
	belongs_to :order_by_masseuse,foreign_key: 'from_order_id'
	belongs_to :qrcode_log
	belongs_to :member
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :ab_recommended_project,class_name: 'UserAbProjectsCouponsRulesRecommendedProject',foreign_key: 'projects_id'
	belongs_to :coupons_class,foreign_key: 'coupons_classes_id'

	def sent_message(sangna_config,wechat_config,hand_code)
			templete=TempleteNumber.find_by_topic('卡券核销通知')	
			message=templete.templete_messages.where(sangna_config_id:sangna_config.id).first

			hash={}
			hash["first"]="您此次核销的卡卷是用于#{hand_code}锁牌"
			hash["remark"]="#{sangna_config.per_user.name}期待您再次的光临!"
			array=['代金券','任何项目',Time.now.strftime("%Y年%m月%d日 %H:%M")]
			templete.fields.split(',').each_with_index do |a,index|
				  hash[a]=array[index]
			end
			url="http://weixin.linkke.cn/wechat/wc_front/my_account?appid=#{sangna_config.appid}"
			Sangna.sent_template_message(sangna_config.token,wechat_config.openid,message.templete_id,url,hash)
	end
end
