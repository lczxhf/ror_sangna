class Wechat::GzhManageController < ApplicationController
	require 'net/http'
  	require "nokogiri"
  	APPID="wxf6a05c0e64bc48e1"
  	def set_menu
        gzh=SangnaConfig.find(params[:id])
        if Time.now-gzh.updated_at>=7200
              result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),APPID,gzh.appid,gzh.refresh_token))
							if result['authorizer_refresh_token']
								gzh.refresh_token=result['authorizer_refresh_token']
								gzh.token=result['authorizer_access_token']
								gzh.save
							end
        end
        url='https://api.weixin.qq.com/cgi-bin/menu/create?access_token='+gzh.token
		#body='{"button":[{"name":"扫码","sub_button":[{"type":"scancode_waitmsg","name":"扫码带提示","key":"rselfmenu_0_0","sub_button":[]},{"type":"scancode_push","name":"扫码推事件","key":"rselfmenu_0_1","sub_button":[]}]},{"name":"发图","sub_button":[{"type":"pic_sysphoto","name":"系统拍照发图","key":"rselfmenu_1_0","sub_button":[]},{"type":"pic_photo_or_album","name":"拍照或者相册发图","key":"rselfmenu_1_1","sub_button":[]},{"type":"pic_weixin","name":"微信相册发图","key":"rselfmenu_1_2","sub_button":[]}]},{"name":"发送位置","type":"location_select","key":"rselfmenu_2_0"}]}'
		#body='{"button":[{"name":"发图","sub_button":[{"type":"pic_sysphoto","name":"系统拍照发图","key":"rselfmenu_1_0","sub_button":[]},{"type":"pic_photo_or_album","name":"拍照或者相册发图","key":"rselfmenu_1_1","sub_button":[]},{"type":"pic_weixin","name":"微信相册发图","key":"rselfmenu_1_2","sub_button":[]}]},{"type":"media_id","name":"图片","media_id":"MEDIA_ID1"},{"type":"view_limited","name":"图文消息","media_id":"MEDIA_ID2"}]}'
        hash=
          {
          "button" => MenuInfo.where(level:1).collect do |menu|
                       a={}
                       a["name"]=menu.name
                       if menu.m_type=="sub_button"
                           sub=menu.menu_infos.collect do |sub_menu|
                              b={}
                              b["name"]=sub_menu.name
                              b["type"]=sub_menu.m_type
                              if sub_menu.m_type=="view"
                                 b["url"]=sub_menu.content+"?appid="+gzh.appid
                              else
                                 b["key"]=sub_menu.content
                              end
                               b
                           end
                          a["sub_button"]=sub
                       else
                           a["type"]=menu.m_type
                           if menu.m_type=="view"
                           a["url"]=menu.content+"?appid="+gzh.appid
                       else
                            a["key"]=menu.content
                        end
                     end
                     a
                  end
     }
      body=hash.to_s.gsub("=>",":")
      result=ThirdParty.sent_to_wechat(url,body)
		  puts result
      if params[:authorize]
          redirect_to("http://linkke.cn/weixin_set?status=ok")
      else
         render nothing: true
      end

  	end



    def authorize
    if params[:appid]
			puts params
      gzh=SangnaConfig.where(appid:params[:appid]).first
			 if Time.now-gzh.updated_at>=7200
				     result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),appid,gzh.appid,gzh.refresh_token))
						 if result['authorizer_refresh_token']
								gzh.refresh_token=result['authorizer_refresh_token']
								gzh.token=result['authorizer_access_token']
								gzh.save
						 end
			end
      url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{gzh.appid}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{APPID}&component_access_token="+Rails.cache.read(:access_token)
			puts url
      result=JSON.parse(ThirdParty.get_to_wechat(url))
      puts result
      if previous=WechatConfig.where(openid:result['openid'],sangna_config_id:gzh.id).first
         wechat_config=previous

      else
          wechat_config=WechatConfig.new
      end
			cookies.signed["#{params[:appid]}_openid"]=result["openid"]
      wechat_config.sangna_config=gzh
      wechat_config.code=params[:code]
      wechat_config.token=result['access_token']
      wechat_config.refresh_token=result['refresh_token']
      wechat_config.openid=result['openid']
      wechat_config.scope=result['scope']
			 if !wechat_config.member
				   member=Member.create(user_id:gzh.per_user.id,username:wechat_config.openid)
					 wechat_config.member=member
			 end
			 wechat_config.save
      Sangna.get_oauth2_info(wechat_config.id,APPID)
			next_url=cookies.signed[:next_url]
			cookies.delete(:next_url)
      redirect_to next_url
    end
  end

	  def oauth
          url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{params[:appid]}&code=#{params[:code]}&grant_type=authorization_code&component_appid=wxf6a05c0e64bc48e1&component_access_token="+Rails.cache.read(:access_token) 
          result=JSON.parse(ThirdParty.get_to_wechat(url))
					puts result
					if result["openid"]
						if WechatConfig.find_by_openid(result["openid"])
						else
							sangna_config=SangnaConfig.find_by_appid(params[:appid])
							wechat_config=WechatConfig.new
							wechat_config.openid=result['openid']
							wechat_config.sangna_config_id=sangna_config.id
							wechat_config.del=2
							wechat_config.save
							wechat_config.create_member(username:result['openid'],user_id:sangna_config.per_user_id)
							wechat_config.create_wechat_user(nickname:'未关注',del:2,member_id:wechat_config.member_id)
						#	url2="https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{params[:appid]}&redirect_uri=http://weixin.linkke.cn/wechat/gzh_manage/authorize&response_type=code&scope=snsapi_userinfo&state=200&component_appid=#{APPID}#wechat_redirect'"
						#	redirect_to url2
						end
							if params[:state]=='200'
									cookies.signed[:p_openid]=result["openid"]
							else
									cookies.signed["#{params[:appid]}_openid"]=result["openid"]
							end
					end
							next_url=cookies.signed[:next_url]
							cookies.delete(:next_url)
							redirect_to next_url
		end

		def change_qrcode_test
					puts params
					qrcode=PerUserQrCode.where(user_id:params[:user_id],hand_code:params[:hand_code],id_code:params[:id_code]).first
					if qrcode
							if qrcode.status==1
									qrcode.status=2
									qrcode.save
									puts 'jihuo'
									render plain: "激活"
							else
									 member=Member.where(user_id:params[:user_id],hand_code:qrcode.hand_code).first
									if member
												qrcode.status=1
												member.hand_code=""
												member.save
												qrcode.save
												puts 'jieban'
										render plain: "解绑"
									else
												per_user=PerUser.includes(:sangna_config).find(params[:user_id])
												wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{per_user.sangna_config.appid}_openid"])
												wechat_config.member.hand_code=qrcode.hand_code
												wechat_config.member.save
												wechat_config.member.coupons_records.where(status:1).each do |a|
														a.status=2
														a.save
												end
												puts 'jinchang'
												redirect_to 'http://weixin.linkke.cn/wechat/wc_front/choose_technician?appid='+per_user.sangna_config.appid
									end
							end
					else
								render nothing: true
					end
		end

		def change_qrcode
			puts params
			per_user=PerUser.includes(:sangna_config).find(params[:user_id])
			if !cookies["#{per_user.sangna_config.appid}_openid"]	|| WechatConfig.find_by_openid(cookies.signed["#{per_user.sangna_config.appid}_openid"]).nil?
				cookies.signed[:next_url]=request.url
				auth_url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{per_user.sangna_config.appid}&redirect_uri=http://weixin.linkke.cn/wechat/gzh_manage/oauth&response_type=code&scope=snsapi_base&state=123&component_appid=wxf6a05c0e64bc48e1#wechat_redirect"                    
		   		redirect_to auth_url
			else
			wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{per_user.sangna_config.appid}_openid"])

			if params[:sex].nil?
				qrcode=PerUserQrCode.where(user_id:params[:user_id],hand_code:params[:hand_code],id_code:params[:id_code],del:1).first
			else 
				qrcode=PerUserQrCode.where(user_id:params[:user_id],hand_code:params[:hand_code],id_code:params[:id_code],sex:params[:sex],del:1).first
			end
			record=ScanQrcodeRecord.create(user_id:per_user.id,member_id:wechat_config.member_id,status:wechat_config.del,hand_code:qrcode.hand_code)
			if wechat_config && wechat_config.try(:del)==1	
				if !wechat_config.member.per_user_qr_code
					if qrcode.status==1
							puts 'status was 1'
							@error_status=2
							render "/wechat/wc_front/wechat_error"
					else
						if per_user.member.where(hand_code:qrcode.id).first || (Rails.cache.exist?("#{qrcode.id}_entrance") && Rails.cache.read("#{qrcode.id}_entrance")!=wechat_config.openid)
							puts 'hand_code had been bind'
								@error_status=1
								render template: '/wechat/wc_front/wechat_error'
						else
							wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{per_user.sangna_config.appid}_openid"])
							log=qrcode.qrcode_logs.last 
							if log.nil? || log.member
								log=qrcode.qrcode_logs.build
								log.created_at=Time.new('2000-01-01')
							end
							log.member=wechat_config.member
							log.member_bind_time=Time.now
							coupons_records=wechat_config.member.coupons_records.where("status in (1,2)")
							log.entrance_card_count=coupons_records.size
							log.entrance_card_sum=coupons_records.collect{|a| a.value}.sum
							log.save
							wechat_config.member.hand_code=qrcode.id
							wechat_config.member.save
							coupons_records.each do |a|
								a.status=2
								a.save
							end
							puts 'jinchang'
							redirect_to 'http://weixin.linkke.cn/wechat/wc_front/choose_technician?appid='+per_user.sangna_config.appid	
						end
					end
				else
								#@error_status=2
								#render template: '/wechat/wc_front/wechat_error'
								puts 'member had been bind'
								redirect_to 'http://weixin.linkke.cn/wechat/wc_front/choose_technician?appid='+per_user.sangna_config.appid
				end

			else
						Rails.cache.write("#{wechat_config.openid}_entrance",qrcode.id,expires_in: 3.hours)
						Rails.cache.write("#{qrcode.id}_entrance",wechat_config.openid,expires_in: 3.hours)
						puts 'must use scan by page'
						params.delete(:controller)
						params.delete(:action)
						redirect_to '/wechat/wc_front/tip?appid='+per_user.sangna_config.appid+"&#{params.to_param}"
			end
	end
end
		
		def sent_card_message
			card_ids=params[:card_ids].split(',')
			coupons_records=CouponsRecord.find(card_ids)
			if coupons_records.all? {|a| a.status==2}
				if coupons_records.first.sent_message(coupons_records.first.per_user.sangna_config,coupons_records.first.member.wechat_config,card_ids)['errmsg']=='ok'
					render plain: true
				else
					render plain: false
				end
			else
				render plain: false
			end
		end

		def sent_consumption_message
							puts params
								order=OrderByMasseuse.includes(:member,:per_user_masseuse,:per_user_project,:per_user).where(id:params[:o_id],status:2,del:1,is_reviewed:1).first
					#	if order.per_user_qr_code.hand_code==params[:h]
							  gzh=order.per_user.sangna_config
								if Time.now-gzh.updated_at>=7200
									result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),APPID,gzh.appid,gzh.refresh_token))
									if result['authorizer_refresh_token']
											gzh.refresh_token=result['authorizer_refresh_token']
											gzh.token=result['authorizer_access_token']
											gzh.save
									end
								end
								hash={}
								url="http://weixin.linkke.cn/wechat/wc_front/technician_remark_level?o_id=#{params[:o_id]}&appid=#{order.per_user.sangna_config.appid}"
								if rule=order.per_user.coupons_rules.where(name:'分享得红包',status:1).first
										#templete_number=TempleteNumber.find_by_topic('获得优惠券通知')	
										url=url+"&l=z&same="+rule.same_id
										#hash["first"]="您还有一个优惠劵未领取！\\n#{order.per_user.name}#{order.per_user_masseuse.job_number}号技师已经为您完成了#{order.per_user_project.name}服务"
										#hash["remark"]="点击“详情”获取代金券!"
										#coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:2).first
										#array=[coupon_rule.face_value.to_s+'元代金券','所有项目',coupon_rule.due_day.to_s+"天"]
								else
									url=url+'&l=h'
								end
										templete_number=TempleteNumber.find_by_topic('服务完成通知')
										hash['first']="#{order.per_user.name}#{order.per_user_masseuse.job_number}号技师为您的服务已经完成"
										hash['remark']='您可以点击\"详情\"为'+order.per_user_masseuse.job_number+'号技师评价并分享体验给朋友'
										array=[order.per_user_project.name,order.end_time.strftime("%Y年%m月%d日 %H:%M")]
								templete_message=templete_number.templete_messages.where(sangna_config_id:order.per_user.sangna_config.id).first
								templete_number.fields.split(',').each_with_index do |a,index|
												hash[a]=array[index]	
								end

								puts hash.to_json
								Sangna.sent_template_message(order.per_user.sangna_config.token,order.member.wechat_config.openid,templete_message.templete_id,url,hash)

					#	end
								render nothing: true
		end



		def sent_custom_message
					sangna_config=SangnaConfig.find(params[:id])
					 if Time.now-sangna_config.updated_at>=7200
                result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),APPID,sangna_config.appid,sangna_config.refresh_token))
								if result['authorizer_refresh_token']
										sangna_config.refresh_token=result['authorizer_refresh_token']
										sangna_config.token=result['authorizer_access_token']
										sangna_config.save
								end
          end
					url="https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token="+sangna_config.token
					body='{"touser":"'+params[:openid]+'","msgtype":"text","text":{"content":"'+params[:content]+'"}}'
				result=	ThirdParty.sent_to_wechat(url,body)
				 render plain: result
		end
end
