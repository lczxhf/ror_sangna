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
		if  coupons_class=CouponsClass.where(id:2,del:1,status:1).first
				if user_coupons_class=coupons_class.user_coupons_classes.where(user_id:per_user_id,status:1).first
					is_open=true
				end
		end
		is_open
	end

	#发送wifi推送的模板消息
	def sent_wifi_message(wechat_config)
		templete=TempleteNumber.find_by_topic('入场成功通知')	
		message=templete.templete_messages.where(sangna_config_id:self.sangna_config.id).first
		hash={}
		hash["first"]="恭喜您已经成功入场!"
		hash["remark"]="点击即可查看更多信息!"
		array=[self.name,'点击查看']
		templete.fields.split(',').each_with_index do |a,index|
			 hash[a]=array[index]
		end
		sangna_config=self.sangna_config
		if Time.now-sangna_config.updated_at>=7200
					result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),"wxf6a05c0e64bc48e1",sangna_config.appid,sangna_config.refresh_token))
					if result['authorizer_refresh_token']
						sangna_config.refresh_token=result['authorizer_refresh_token']
						sangna_config.token=result['authorizer_access_token']
						sangna_config.save
					end
		end
		url="http://weixin.linkke.cn/wechat/wc_front/wifi_page?appid=#{sangna_config.appid}"
		Sangna.sent_template_message(sangna_config.token,wechat_config.openid,message.templete_id,url,hash)
	end

	def get_forward_img
		if per_user_imgs.empty?
			'http://linkke.cn/huisuo_img'
		else
			"http://linkke.cn#{per_user_imgs.first.url.thumb.url}"
		end
	end
end
