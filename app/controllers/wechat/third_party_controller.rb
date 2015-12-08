class Wechat::ThirdPartyController < ApplicationController
	require 'nokogiri'
	require 'net/http/post/multipart'
	TOKEN="tiandiwang"
	KEY="IuvWqPHol3TrXsLYMuOKisVFjewCwIUJBJ6ucMBKjp8"
	APPID="wxf6a05c0e64bc48e1"
	APPSECRET="0c79e1fa963cd80cc0be99b20a18faeb"
	 include Wechat::ReplyWeixinMessageHelper

	def test
		#	masseuse=PerUserMasseuse.find_by_job_number(1234)
		#	Dir::foreach('/home/lzh/1234') do |dir|
		#			if file=(/\w+\.[a-zA-Z0-9]+/.match(dir))
		#				    file="/home/lzh/1234/"+file.to_s
		#				    puts file
							# File::open(file,'r') do |a|
							# 	img=MasseusesImg.new
							# 	img.per_user_masseuse=masseuse
							# 	img.url=a
							# 	img.i_type=2
							# 	img.user_id=masseuse.user_id
							# 	img.save
							# end
		#			end
		#	end
		# sangna=SangnaConfig.first
		# a=Sangna.get_qrcode(sangna.token,'QR_SCENE',"6000","123")['ticket']
		#ab=Sangna.fetch_qrcode(a)
		#img=MiniMagick::Image.read ab
		#img.format 'png'
		#PerUserImg.create!(user_id:1,status:1,i_type:1,url:img)
	
#code=rand(1000..9999).to_s
#		 uri = URI("http://222.73.117.158/msg/HttpBatchSendSM")
#			Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
#					request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
#					request.set_form_data({"account"=>"jiekou-clcs-005","pswd"=>"Clwh16816868","mobile"=>"15817378124","msg"=>"您好，您的手机验证码是#{code}，如非本人操作请忽略！","needstatus"=>"true",})
#					response=http.request request
#					a=response.body
#					a=a.split("\n")
#					#result= REXML::Document.new a
#					#render plain:  result.root.get_elements('msg')[0][0].to_s
#					render plain: a.inspect
#			end
		Dir::foreach('/home/rails-server/Projects/0') do |file_name|
				if file=(/\w+\.[a-zA-Z0-9]+/.match(file_name))
						file="/home/rails-server/Projects/0/"+file.to_s
						File.open(file,'r') do |img|
							file_name.gsub!(/[\.]{1}.*/,"")	
							if technician=PerUserMasseuse.where(user_id:0,job_number:file_name,del:1,status:1).first
									if technician.masseuses_imgs.empty?
									masseuses_img=MasseusesImg.new		
									masseuses_img.user_id=0
									masseuses_img.per_user_masseuse=technician
									masseuses_img.url=img
									masseuses_img.i_type=1
									masseuses_img.save
									end
							end
						end
				end
		end
  end

def test1
	#	SangnaConfig.all.each do |sangna_config|
  #    	qrcode=ThirdParty.get_to_wechat(sangna_config.sangna_info.qrcode_url)
  #      img=MiniMagick::Image.read qrcode
  #      img.format 'png'
  #      sangna_config.original_qr_code=img
  #      sangna_config.save
  #  	end
	   if params[:get]='true'
	   get_previous_data(SangnaConfig.find(params[:id]))
		 end
		 render nothing: true
end	

def authorize
		cookies.signed[:admin]=params[:my_name]
		redirect_to '/admin'
end
	 def home 
		@url="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{APPID}&pre_auth_code=#{Rails.cache.read(:pre_code)}&redirect_uri=http://weixin.linkke.cn/wechat/third_party/auth_code?id=#{params[:id]}"
 	 	render :home,:layout=>false
 	 end
 	def receive
			puts params
		str=request.body.read
		doc=Nokogiri::Slop str
		ticket=doc.xml.Encrypt.content	
			
		if ThirdParty.check_info(TOKEN,params[:timestamp],params[:nonce],ticket,params[:msg_signature])
			result=ThirdParty.new.decrypt(ticket.to_s,KEY,APPID)
			xml=Nokogiri::Slop result
			if xml.xml.InfoType.content.to_s=='component_verify_ticket'
			   verify_ticket=xml.xml.ComponentVerifyTicket.content.to_s
			   Rails.cache.write(:ticket,verify_ticket)
				 Rails.cache.write(:access_token_time,(Rails.cache.read(:access_token_time) || 0)+1)
				 if (access_token=Rails.cache.read(:access_token)).nil? || Rails.cache.read(:access_token_time)==9
						url='https://api.weixin.qq.com/cgi-bin/component/api_component_token'
						body='{"component_appid":"'+APPID+'","component_appsecret":"'+APPSECRET+'","component_verify_ticket":"'+verify_ticket+'"}'
						a=JSON.parse(ThirdParty.sent_to_wechat(url,body))
						puts a
						access_token=a["component_access_token"]
						Rails.cache.write(:access_token,access_token,expires_in: 90.minutes)
						Rails.cache.write(:access_token_time,0)
				 end
			   url='https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token='+access_token
			   body='{"component_appid":"'+APPID+'"}'
			   pre_auth_code=JSON.parse(ThirdParty.sent_to_wechat(url,body))
			   Rails.cache.write(:pre_code,pre_auth_code["pre_auth_code"])
			else
			   appid=xml.xml.AuthorizerAppid.content.to_s
			   SangnaConfig.where(appid:appid).first.update_attribute(:del,2)
			end
		else
			puts 'error'
		end
		render plain: 'success'
	 end


 def auth_code 
	puts params
	url='https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token='+Rails.cache.read(:access_token)
  body='{"component_appid":"'+APPID+'","authorization_code":"'+params[:auth_code]+'"}'
  result=ThirdParty.sent_to_wechat(url,body)
	puts result.to_json
	json=JSON.parse(result)
	auth_code=SangnaConfig.find_or_initialize_by(appid:json['authorization_info']['authorizer_appid'])
	auth_code.code=params[:auth_code]
	auth_code.token=json['authorization_info']['authorizer_access_token']
	auth_code.del=1
	auth_code.per_user_id=params[:id]
	auth_code.refresh_token=json['authorization_info']['authorizer_refresh_token']
		qrcode=Sangna.get_qrcode(auth_code.token,'QR_LIMIT_SCENE',"","1")
		puts qrcode
		qrcode=Sangna.fetch_qrcode(qrcode['ticket'])
		img=MiniMagick::Image.read qrcode
		img.format 'png'
		img.resize '190x190'
		auth_code.qr_code=img
	arr=[]
	json['authorization_info']['func_info'].each do |a|
		arr<<a['funcscope_category']['id']
	end
	auth_code.func_info=arr.join(',')
	auth_code.save
	change_qrcode(auth_code)
	#get_previous_data(auth_code)
	GetUserInfo.perform_async(auth_code.token,auth_code.id)
	Group.find_or_create_by(sangna_config_id:auth_code.id,wcgroup_id:'0',name:'默认组')
	redirect_to :action=>'gzh_info',id:auth_code.id
 end

 def gzh_info 
	auth_code=SangnaConfig.find(params[:id])
	if auth_code.sangna_info
	   sangna_info=auth_code.sangna_info
	else
	   sangna_info=SangnaInfo.new
	   sangna_info.sangna_config=auth_code
	end
	url='https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_info?component_access_token='+Rails.cache.read(:access_token)
	body='{"component_appid":"'+APPID+'","authorizer_appid":"'+auth_code.appid+'"}'
	result=JSON.parse(ThirdParty.sent_to_wechat(url,body))['authorizer_info']
	sangna_info.nickname=result['nick_name']
	sangna_info.headimgurl=result['head_img']
	sangna_info.service_type=result['service_type_info']['id']
	sangna_info.verify_type=result['verify_type_info']['id']
	sangna_info.user_name=result['user_name']
	sangna_info.alias=result['alias']
	sangna_info.qrcode_url=result['qrcode_url']
	qrcode=ThirdParty.get_to_wechat(sangna_info.qrcode_url)
        img=MiniMagick::Image.read qrcode
        img.format 'png'
        auth_code.original_qr_code=img
        auth_code.save
	puts sangna_info.to_json
	sangna_info.save
	redirect_to :action=>'option_info',id:auth_code.id
 end

 def option_info 
	auth_code=SangnaConfig.find(params[:id])
	option=['location_report','voice_recognize','customer_service']
	url='https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_option?component_access_token='+Rails.cache.read(:access_token)
	option.each do |a|
	  body='{"component_appid":"'+APPID+'","authorizer_appid":"'+auth_code.appid+'","option_name":"'+a+'"}'
	  result=JSON.parse(ThirdParty.sent_to_wechat(url,body))['option_value']
	  auth_code.sangna_info.send(a+'=',result)
	end
	auth_code.sangna_info.save
	redirect_to :action=>'set_industry',id:auth_code.id
	# render nothing: true
  end

   def set_industry
     sangna_config=SangnaConfig.find(params[:id])
      one='39'
      two='24'
      url="https://api.weixin.qq.com/cgi-bin/template/api_set_industry?access_token="+sangna_config.token
		   body='{"industry_id1":"'+one+'","industry_id2":"'+two+'"}'
       ThirdParty.sent_to_wechat(url,body)
			# sleep 500
      url2="https://api.weixin.qq.com/cgi-bin/template/api_add_template?access_token="+sangna_config.token
      TempleteNumber.find_each do |templete|
					if !sangna_config.templete_messages.where(templete_number_id:templete.id).first
      		body2='{"template_id_short":"'+templete.number+'"}'
					result=ThirdParty.sent_to_wechat(url2,body2)
					puts result
      		templete_id=JSON.parse(result)["template_id"]
      		t_message=TempleteMessage.new
      		t_message.templete_id=templete_id
      		t_message.sangna_config=sangna_config
      		t_message.templete_number=templete
      		t_message.save!
					end
      end
   	  redirect_to :controller=>"gzh_manage",:action=>'set_menu',id:sangna_config.id,:authorize=>true
   end
		
	private
		def change_qrcode(sangna_config)
				MiniMagick::Tool::Convert.new do |convert|
							# convert << "+append"
							#	convert << Rails.root.join("public","images","gaokede.png")
							#	convert << Rails.root.join("public","images","zhiwu.png")	
							#	convert << Rails.root.join("public","images","result.png")	
							convert << '-size'
							convert << '380x190'
							convert << '-strip'
							convert << 'xc:none'
							convert <<  Rails.root.to_s+'/public'+sangna_config.qr_code.url
							convert << '-geometry'
							convert << '+0+0'
							convert << '-composite'
							convert << Rails.root.join("public","images","zhiwu.png")	
							convert << '-geometry'
							convert << '+190+0'
							convert << '-composite'
							convert << Rails.root.to_s+'/public'+sangna_config.qr_code.url
				end
		end

		def get_previous_data(auth_code,next_openid=nil,susplus=0)
					url='https://api.weixin.qq.com/cgi-bin/user/get?access_token='+auth_code.token+(next_openid.nil? ? '' : "next_openid=#{next_openid}")
					info_result=JSON.parse(ThirdParty.get_to_wechat(url))
					puts info_result.to_json
					if info_result['count'].to_i>0
						if next_openid.nil?
								susplus=info_result['total'].to_i-info_result['count'].to_i
						end
				   		if arr=info_result['data']['openid']
				   			arr.to_a.each do |openid|
				   					if !WechatConfig.where(openid:openid).first
				   							wechat_config=WechatConfig.new(openid:openid,sangna_config_id: auth_code.id)
				   							wechat_config.del=1
				   							if !wechat_config.member
				   								member=Member.create(user_id:params[:id],username:wechat_config.openid)
				   								wechat_config.member=member
				   							end
				   							wechat_config.save
				   							Sangna.get_user_info(wechat_config.id,APPID)
				   					end
										if susplus>0
												get_previous_data(auth_code,info_result['next_openid'],susplus)
										end
				   			end
				   		end
					end
		end
end
