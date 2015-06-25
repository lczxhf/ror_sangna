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
                                 b["url"]=sub_menu.content
                              else
                                 b["key"]=sub_menu.content
                              end
                               b
                           end
                          a["sub_button"]=sub
                       else
                           a["type"]=menu.m_type
                           if menu.m_type=="view"
                           a["url"]=menu.content
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
      render nothing: true
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
      wechat_config.sangna_config=gzh
      wechat_config.code=params[:code]
      wechat_config.token=result['access_token']
      wechat_config.refresh_token=result['refresh_token']
      wechat_config.openid=result['openid']
      wechat_config.scope=result['scope']
      wechat_config.save
      redirect_to :action=>'get_info',:id=>wechat_config._id
    end
  end
  
  def get_info
    wechat_config=WechatConfig.find(params[:id])
    sangna_config=wechat_config.sangna_config
    if Time.now-sangna_config.updated_at>=7200
              result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),APPID,sangna_config.appid,sangna_config.refresh_token))
              sangna_config.refresh_token=result['authorizer_refresh_token']
              sangna_config.token=result['authorizer_access_token']
              sangna_config.save
    end
    url="https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{sangna_config.token}&openid=#{wechat_config.openid}&lang=zh_CN"
    info=JSON.parse(ThirdParty.get_to_wechat(url)) 
    puts info
    wechat_user=WechatUser.new
    wechat_user.nick_name=info['nickname']
    wechat_user.sex=info['sex']=='1'?true:false
    wechat_user.province=info['province']
    wechat_user.city=info['city']
    wechat_user.country=info['country']
    wechat_user.head_image=info['headimgurl']
    #wechat_user.unionid=info['unionid']
    wechat_user.subscribe_time=info['subscribe_time']
    wechat_user.remark=info['remark']
    wechat_user.group=Group.where(wcgroup_id:info["groupid"],sangna_config_id:sangna_config._id).first
    wechat_user.wechat_config=wechat_config
    wechat_user.save
    hash={}
    hash['first']='恭喜你成为速达易会员'
    hash['keyword1']=info['nickname']
    hash['keyword2']=(Time.now+1.year).strftime('%Y%m%d').to_s
    hash['remark']='更多详情请关注速达易'
     Sangna.sent_template_message(wechat_config.sangna_config.token,wechat_config.openid,"E3PgD8slAbZ03ZvYVtD_S5y-ekdTKpSXs64docm8Ojc","http://shop.29mins.com/wechats/home",hash)

    render nothing:true 
  end

end
