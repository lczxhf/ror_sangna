class Wechat::ThirdPartyController < ApplicationController
	require 'nokogiri'
	require 'net/http/post/multipart'
	TOKEN="tiandiwang"
	KEY="IuvWqPHol3TrXsLYMuOKisVFjewCwIUJBJ6ucMBKjp8"
	APPID="wxf6a05c0e64bc48e1"
	APPSECRET="0c79e1fa963cd80cc0be99b20a18faeb"
	 def home 
		@url="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{APPID}&pre_auth_code=#{Rails.cache.read(:pre_code)}&redirect_uri=http://weixin.linkke.cn/wechat/third_party/auth_code"
 	 end
 	def receive
    	puts params
		str=request.body.read
		puts str
		doc=Nokogiri::Slop str
		ticket=doc.xml.Encrypt.content	
	
		if ThirdParty.check_info(TOKEN,params[:timestamp],params[:nonce],ticket,params[:msg_signature])
			result=ThirdParty.new.decrypt(ticket.to_s,KEY,APPID)
			puts result
			xml=Nokogiri::Slop result
			if xml.xml.InfoType.content.to_s=='component_verify_ticket'
			   verify_ticket=xml.xml.ComponentVerifyTicket.content
			   Rails.cache.write(:ticket,verify_ticket.to_s)
			   url='https://api.weixin.qq.com/cgi-bin/component/api_component_token'
			   body='{"component_appid":"'+APPID+'","component_appsecret":"'+APPSECRET+'","component_verify_ticket":"'+Rails.cache.read(:ticket)+'"}'
			   access_token=JSON.parse(ThirdParty.sent_to_wechat(url,body))['component_access_token']
			   Rails.cache.write(:access_token,access_token)
			   url='https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token='+access_token
			   body='{"component_appid":"'+APPID+'"}'
			   pre_auth_code=JSON.parse(ThirdParty.sent_to_wechat(url,body))['pre_auth_code']
			   Rails.cache.write(:pre_code,pre_auth_code)
			else
			   appid=xml_root.get_elements('AuthorizerAppid')[0][0].to_s
			   SangnaConfig.where(appid:appid).first.delete
			end
		else
			puts 'error'
		end
		render plain:'success'
	 end


 def auth_code 
	puts params
	
	url='https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token='+Rails.cache.read(:access_token)
	body='{"component_appid":"'+APPID+'"," authorization_code": "'+params[:auth_code]+'"}'
	puts body
	result=ThirdParty.sent_to_wechat(url,body)
	auth_code=SangnaConfig.create(code:params[:auth_code])
	puts result.to_json
	redirect_to :action=>'gzh_parameter',:auth_code_id=>auth_code._id
 end

 def gzh_parameter 
	auth_code=SangnaConfig.find(params[:auth_code_id])
	url='https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token='+Rails.cache.read(:access_token)
        body='{"component_appid":"'+APPID+'","authorization_code":"'+auth_code.code+'"}'
        result=ThirdParty.sent_to_wechat(url,body)
	puts result.to_json
	json=JSON.parse(result)
	auth_code.token=json['authorization_info']['authorizer_access_token']
	auth_code.appid=json['authorization_info']['authorizer_appid']
	auth_code.refresh_token=json['authorization_info']['authorizer_refresh_token']
	arr=[]
	json['authorization_info']['func_info'].each do |a|
		arr<<a['funcscope_category']['id']
	end
	auth_code.func_info=arr.join
	auth_code.save
	redirect_to :action=>'gzh_info',auth_code_id:auth_code._id
 end

 def gzh_info 
	auth_code=SangnaConfig.find(params[:auth_code_id])
	if auth_code.sangna_info
	   sangna_info=auth_code.sangna_info
	else
	   sangna_info=SangnaInfo.new
	   sangna_info.sangna_config=auth_code
	end
	url='https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_info?component_access_token='+Rails.cache.read(:access_token)
	body='{"component_appid":"'+APPID+'","authorizer_appid":"'+auth_code.appid+'"}'
	result=JSON.parse(ThirdParty.sent_to_wechat(url,body))['authorizer_info']
	sangna_info.nick_name=result['nick_name']
	sangna_info.head_image=result['head_img']
	sangna_info.service_type=result['service_type_info']['id']
	sangna_info.verify_type=result['verify_type_info']['id']
	sangna_info.user_name=result['user_name']
	sangna_info.alias=result['alias']
	sangna_info.qrcode_url=result['qrcode_url']
	sangna_info.save
	redirect_to :action=>'option_info',auth_code_id:auth_code._id
 end

 def option_info 
	auth_code=SangnaConfig.find(params[:auth_code_id])
	option=['location_report','voice_recognize','customer_service']
	url='https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_option?component_access_token='+Rails.cache.read(:access_token)
	option.each do |a|
	  body='{"component_appid":"'+APPID+'","authorizer_appid":"'+auth_code.appid+'","option_name":"'+a+'"}'
	  result=JSON.parse(ThirdParty.sent_to_wechat(url,body))['option_value']
	  auth_code.sangna_info.send(a+'=',result)
	end
	auth_code.sangna_info.save
	render plain:'ok'
  end
end
