require 'sidekiq/api'
class SentEnterCard
	include Sidekiq::Worker
	def perform(member_id,user_id,log_id,openid)
			puts "sent #{member_id} enter card"
			per_user = PerUser.find(user_id)
			if rule=CouponsRule.where(user_id:per_user.id,status:1,coupons_type:3,coupons_classes_id:6).first
				card = CouponsRecord.new
				card.coupons_rules_id = rule.id
				card.user_id = user_id 
				card.member_id = member_id
				card.status = 1
				o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
				string = (0...4).map{ o[rand(o.length)] }.join
				card.number=Time.now.to_i.to_s+string
				card.value = rule.face_value
				card.coupons_classes_id = 6
				card.departure_log_id =log_id
				if card.save
						templete_number=TempleteNumber.find_by_topic('获得优惠券通知')
						hash={}
						url="http://weixin.linkke.cn/wechat/wc_front/card_info?appid=#{per_user.sangna_config.appid}"
						hash['first']="感谢您在#{per_user.name}的消费!"
						hash['remark']='送你一张代金券!'
						array=['代金券','所有项目',"#{rule.due_day}天"]
						templete_message=templete_number.templete_messages.where(sangna_config_id:per_user.sangna_config.id).first
						templete_number.fields.split(',').each_with_index do |a,index|
						      hash[a]=array[index]
						end
						puts Sangna.sent_template_message(per_user.sangna_config.token,openid,templete_message.templete_id,url,hash)	
				end
			end
	end
end 
																																			         
