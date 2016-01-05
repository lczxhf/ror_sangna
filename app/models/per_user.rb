class PerUser < ActiveRecord::Base
	has_one :sangna_config
	has_one :per_user_info,foreign_key: "user_id"
	has_many :masseuses_collects
	has_many :per_user_imgs,foreign_key: "user_id"
	has_many :masseuses_imgs,foreign_key: "user_id"
	has_many :per_user_masseuses,foreign_key: "user_id"
	has_many :per_user_qr_codes,foreign_key: "user_id"
	has_many :order_by_masseuses,foreign_key: 'user_id'
	has_many :coupons_rules,foreign_key: 'user_id'
	has_many :coupons_records,foreign_key: 'user_id'
	has_many :user_qr_code_rule,foreign_key: 'user_id'
	has_many :per_user_projects,foreign_key: "user_id"
	has_many :member,foreign_key: 'user_id'
	has_many :user_masseuse_coupons_rule,foreign_key: 'user_id'
	#返回当前会所的完整地址
	#"xx省xx市xx区"
	def get_address
			province=Region.find_by_regions_CODE(province_id)
			city=Region.find_by_regions_CODE(city_id)
			district=Region.find_by_regions_CODE(district_id)
			address=""
			if province
					address+=province.regions_NAME
			end
			if city
					address+=city.regions_NAME
			end
			if district
					address+=district.regions_NAME
			end
			address
	end

	#返回会所是否开启A推B活动
	def self.get_ab_status(per_user_id)
		is_open=false
		#if  coupons_class=CouponsClass.where(id:2,del:1,status:1).first
				if rule=UserAbProjectsCouponsRule.where(user_id:per_user_id,del:1,status:1).first
					is_open=true
				end
		#end
		is_open
	end

	#发送wifi推送的模板消息
	def self.sent_wifi_message(user_id,openid)
		per_user=PerUser.find(user_id)
		templete=TempleteNumber.find_by_topic('入场成功通知')	
		message=templete.templete_messages.where(sangna_config_id:per_user.sangna_config.id).first
		hash={}
		hash["first"]="恭喜您已经成功入场!"
		hash["remark"]="点击即可查看更多信息!"
		array=[per_user.name,'点击查看']
		templete.fields.split(',').each_with_index do |a,index|
			 hash[a]=array[index]
		end
		sangna_config=per_user.sangna_config
		if Time.now-sangna_config.updated_at>=7000
					result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),"wxf6a05c0e64bc48e1",sangna_config.appid,sangna_config.refresh_token))
					if result['authorizer_refresh_token']
						sangna_config.refresh_token=result['authorizer_refresh_token']
						sangna_config.token=result['authorizer_access_token']
						sangna_config.save
						$redis.del(sangna_config.appid)
					end
		end
		url="http://weixin.linkke.cn/wechat/wc_front/wifi_page?appid=#{sangna_config.appid}"
		Sangna.sent_template_message(sangna_config.token,openid,message.templete_id,url,hash)
	end

	def get_forward_img(type)
		if per_user_imgs.empty?
			"http://weixin.linkke.cn/images/#{type}_hs.png"
		else
			"http://linkke.cn#{per_user_imgs.first.url.thumb.url}"
		end
	end

	def get_forward_assets(type)
		 if type=='title'
		 	area=Region.where(regions_code:district_id).first.try(:regions_NAME)
		 	city=Region.where(regions_code:city_id).first.try(:regions_NAME)
		 	[["以后在#{area}放松只去这家店","到场微信选技师，送你们张代金券吧"],["工作这么累！推荐#{area}服务最棒的会所给你放松下","凭优惠券到场服务超值，好东西也给你们瞧一瞧"],["朋友，朋友，我们去哪里呀？#{area}超值场所优惠券等你来抢","反正我不管，我要你陪我去。求关注求点击"],["天啊！#{area}竟然有这么好的去处！简直宅男必备啊","嘘！一般人我可不告诉他！点击进来拿优惠券吧"],["瞧一瞧，看一看！#{area}竟然有这么满意的服务，哇噢！还有优惠券抵消。真是太幸福了","终于找到你，还好我没放弃！好优惠一起抢"],["如果再给我一次休息，我一定会再去一次#{area}这家会所，好好珍惜属于自己的时光","深圳超棒会所，推荐给你"],["相同的选择，不同的期待！#{area}最棒的会所欢迎您","让您开启欢乐时刻，享受美好时光，送你张代金券"]].sample
		 else
		 	url="http://weixin.linkke.cn/images/forward#{rand(1..6)}.png"
		 end
	end
end
