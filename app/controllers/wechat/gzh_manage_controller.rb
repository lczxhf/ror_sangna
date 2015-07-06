class Wechat::GzhManageController < ApplicationController
	require 'net/http'
  	require "nokogiri"
  	APPID="wxf6a05c0e64bc48e1"
  	def set_menu
        gzh=SangnaConfig.find(params[:id])
        if Time.now-gzh.updated_at>=7200
              result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),APPID,gzh.appid,gzh.refresh_token))
              gzh.refresh_token=result['authorizer_refresh_token']
              gzh.token=result['authorizer_access_token']
              gzh.save
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
          redirect_to("www.linkke.cn/wx_weixin/index?appid="+gzh._id)
      else
         render nothing: true
      end

  	end



    def authorize
    if params[:appid]
      gzh=SangnaConfig.where(appid:params[:appid]).first
      url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{gzh.appid}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{APPID}&component_access_token="+Rails.cache.read(:access_token)
      result=JSON.parse(ThirdParty.sent_to_wechat(url,body))
      puts result
      if previous=WechatConfig.where(openid:result['openid'],sangna_config_id:gzh._id).first
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
      wechat_config.save
      Sangna.get_user_info(wechat_config.id,APPID)
			next_url=cookies.signed[:next_url]
      redirect_to next_url
    end
  end

	  def oauth
          puts params
          url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{params[:appid]}&code=#{params[:code]}&grant_type=authorization_code&component_appid=wxf6a05c0e64bc48e1&component_access_token="+Rails.cache.read(:access_token) 
          result=JSON.parse(ThirdParty.get_to_wechat(url))
					if params[:state]=='200'
           cookies.signed[:p_openid]=result["openid"]
					else
						cookies.signed["#{params[:appid]}_openid"]=result["openid"]
					end
							next_url=cookies.signed[:next_url]
							cookies.delete(:next_url)
           redirect_to next_url
     end

		def change_qrcode
					qrcode=PerUserQrCode.where(user_id:params[:user_id],hand_code:params[:hand_code],id_code:params[:id_code]).first
					if qrcode
							if qrcode.status==1
									qrcode.status=2
									qrcode.save
									render plain: "激活"
							else
									 member=Member.where(hand_code:qrcode.hand_code).first
									if member
												qrcode.status=1
												member.hand_code=""
												member.save
												qrcode.save
										render plain: "解绑"
									else
												per_user=PerUser.includes(:sangna_config).find(params[:user_id])
												wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{per_user.sangna_config.appid}_openid"])
												
												wechat_config.member.hand_code=qrcode.hand_code
												wechat_config.member.save
												redirect_to cookies[:next_url]
									end
							end
					else
								render nothing: true
					end
		end


		def sent_custom_message
					sangna_config=SangnaConfig.find(params[:id])
					 if Time.now-sangna_config.updated_at>=7200
                result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),APPID,sangna_config.appid,sangna_config.refresh_token))
                sangna_config.refresh_token=result['authorizer_refresh_token']
                sangna_config.token=result['authorizer_access_token']
                sangna_config.save
          end
					url="https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token="+sangna_config.token
					body='{"touser":"'+params[:openid]+'","msgtype":"text","text":{"content":"U+E728"}}'
				result=	ThirdParty.sent_to_wechat(url,body)
				 render plain: result
		end
end
