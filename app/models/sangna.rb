class Sangna
	require 'net/http/post/multipart'

	#向微信发起刷新token的请求
	#返回xml
	def self.refresh_token(appid,refresh_token,c_appid,c_token)
		url="https://api.weixin.qq.com/sns/oauth2/component/refresh_token?appid=#{appid}&grant_type=refresh_token&component_appid=#{c_appid}&component_access_token=#{c_token}&refresh_token="+refresh_token
		body=""
		ThirdParty.sent_to_wechat(url,body)
	end	
	
	#向微信发起发送模板消息请求!
	#并返回发送结果
	#参数: url为点击模板消息后的跳转页面
	#     hash为填充模板消息内容的键值对
	def self.sent_template_message(token,openid,template_id,url,hash)
		 template_url='https://api.weixin.qq.com/cgi-bin/message/template/send?access_token='+token
				data=""
		    		hash.each do |key,value|
				    data+='"'+key+'":{"value":"'+value+'","color":"#173177"},'
				end	
				data=data[0...data.length-1]
                                template_body='{"touser":"'+openid+'","template_id":"'+template_id+'","url":"'+url+'","topcolor":"#FF0000","data":{'+data+'}}'
                                template_result=JSON.parse(ThirdParty.sent_to_wechat(template_url,template_body))
                                puts template_result
                                template_result
	end


	#向微信请求生成场景二维码
	#并返回请求结果
	#参数: action为二维码的类型
	def self.get_qrcode(token,action,expire="",scene_id="",scene_str="")
	url="https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token="+token
		case action
		when 'QR_SCENE' then
		   body='{"expire_seconds":'+expire.to_s+', "action_name": "QR_SCENE", "action_info": {"scene": {"scene_id":'+scene_id.to_s+'}}}'
		when 'QR_LIMIT_SCENE' then
		   if !scene_id.empty?
		      body='{"action_name": "QR_LIMIT_SCENE", "action_info": {"scene": {"scene_id":'+scene_id+'}}}'
		   else
		      body='{"action_name": "QR_LIMIT_SCENE", "action_info": {"scene": {"scene_str":'+scene_str+'}}}'
		   end
		end
     result=JSON.parse(ThirdParty.sent_to_wechat(url,body))
		result
	end
	

	#根据ticket向微信拿回二维码图片
	def self.fetch_qrcode(ticket)
		url='https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket='+ticket
		ThirdParty.get_to_wechat(url)	
	end
	
	#长链接转短链接
	def self.long2short(token,long_url)
		url='https://api.weixin.qq.com/cgi-bin/shorturl?access_token='+token
		body='{"action":"long2short","long_url":"'+long_url+'"}'
		ThirdParty.sent_to_wechat(url,body)
	end
	
	#上传meida!
	def self.upload_media(token,media,type,name)
		url = URI.parse('https://api.weixin.qq.com/cgi-bin/media/upload?access_token='+token+'&type='+type)
		req = Net::HTTP::Post::Multipart.new url,
  		"media" =>UploadIO.new(media,name)
		res = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
  		http.request(req).body	
	        end
        end
	
	#根据media_id获取media
	def self.get_media(token,media_id)
		url=URI.parse('https://api.weixin.qq.com/cgi-bin/media/get?access_token='+token+'&media_id='+media_id)
		puts 'aa'
		ThirdParty.get_to_wechat(url)
	end
	

	#长传永久media
	def self.upload_forever_media(token,type,media,name,title="",introduction="")
		url=URI.parse('https://api.weixin.qq.com/cgi-bin/material/add_material?access_token='+token)
		   description='{"title":"'+title+'","introduction":"'+introduction+'"}'
		 req = Net::HTTP::Post::Multipart.new url,
     "media" =>UploadIO.new(media,name),
		"type" =>type,
		"description"=>description
                res = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
                http.request(req).body        
                end
	end

	#获取用户的基本信息
	def self.get_user_info(user_id,appid)
		 wechat_config=WechatConfig.includes(:member,:sangna_config).find(user_id)
 	   sangna_config=wechat_config.sangna_config
 	   if Time.now-sangna_config.updated_at>=7000
              result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),appid,sangna_config.appid,sangna_config.refresh_token))
							if result['authorizer_refresh_token']
									sangna_config.refresh_token=result['authorizer_refresh_token']
									sangna_config.token=result['authorizer_access_token']
									sangna_config.save
									$redis.del(sangna_config.appid)
							end
  	 end
 		   url="https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{sangna_config.token}&openid=#{wechat_config.openid}&lang=zh_CN"
 		   info=JSON.parse(ThirdParty.get_to_wechat(url))
 		   puts info
			 if info['subscribe_time']	
					if wechat_config.wechat_user
						wechat_user=wechat_config.wechat_user
					else
						 wechat_user=WechatUser.new
					end
					wechat_user.del=1
					wechat_user.member=wechat_config.member
					wechat_user.nickname=info['nickname']
					wechat_user.sex=info['sex'].to_i
					wechat_user.province=info['province']
					wechat_user.city=info['city']
					wechat_user.country=info['country']
					wechat_user.headimgurl=info['headimgurl']
					wechat_user.language=info['language']
					#wechat_user.unionid=info['unionid']
					wechat_user.subscribe_time=info['subscribe_time']
					wechat_user.remark=info['remark']
					wechat_user.group=Group.where(wcgroup_id:info["groupid"],sangna_config_id:sangna_config.id).first
					wechat_user.wechat_config=wechat_config
					wechat_user.save
			end
	end


	#或者用户的授权信息
	def self.get_oauth2_info(wechat_config_id,appid)
				wechat_config=WechatConfig.includes(:sangna_config).find(wechat_config_id)
				sangna_config=wechat_config.sangna_config
				 if Time.now-sangna_config.updated_at>=4500
					  result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),appid,sangna_config.appid,sangna_config.refresh_token))
						if result['authorizer_refresh_token']
								sangna_config.refresh_token=result['authorizer_refresh_token']
								sangna_config.token=result['authorizer_access_token']
								sangna_config.save
								$redis.del(sangna_config.appid)
						end
				 end
				url="https://api.weixin.qq.com/sns/userinfo?access_token=#{wechat_config.token}&openid=#{wechat_config.openid}&lang=zh_CN"
				info=JSON.parse(ThirdParty.get_to_wechat(url)) 
				puts info
				if a=wechat_config.wechat_user
					 wechat_user=a
				else
						 wechat_user=WechatUser.new
						 wechat_user.wechat_config=wechat_config
				end
				wechat_user.del=wechat_config.del
				wechat_user.member=wechat_config.member
				wechat_user.nickname=info['nickname']
				wechat_user.sex=info['sex'].to_i
				wechat_user.province=info['province']
				wechat_user.city=info['city']
				wechat_user.country=info['country']
				wechat_user.headimgurl=info['headimgurl']
				wechat_user.unionid=info['unionid']
        wechat_user.group=Group.where(wcgroup_id:info["groupid"],sangna_config_id:sangna_config.id).first
				wechat_user.save
	end

	#上传news类型的media
	def self.upload_news(token,array)
		url='https://api.weixin.qq.com/cgi-bin/material/add_news?access_token='+token
		body='{"articles":['
		array.each do |content|
		body+='{"title":"'+content['title']+'","thumb_media_id":"'+content['media_id']+'","author":"'+content['author']+'","digest":"'+content['digest']+'","show_cover_pic":"'+content['is_cover']+'","content":"'+content['content']+'","content_source_url":"'+content['url']+'"},'
		end
		body=body[0...body.length-1]+']}'
		ThirdParty.sent_to_wechat(url,body)
	end
	
	#根据media_id更新media
	def self.update_news(token,media_id,index,hash)
		url='https://api.weixin.qq.com/cgi-bin/material/update_news?access_token='+token
		body='{"media_id":"'+media_id+'","index":"'+index+'","articles":{"title":"'+hash['title']+'","thumb_media_id":"'+hash['media_id']+'","author":"'+hash['author']+'","digest":"'+hash['digest']+'","show_cover_pic":"'+hash['is_cover']+'","content":"'+hash['content']+'","content_source_url":"'+hash['url']+'"}}'
		ThirdParty.sent_to_wechat(url,body)
	end
	
	#根据media_id获取media或者删除media
	def self.get_or_del_forever_media(token,media_id,type='get')
		url='https://api.weixin.qq.com/cgi-bin/material/'+type+'_material?access_token='+token
		body='{"media_id":"'+media_id+'"}'
		ThirdParty.sent_to_wechat(url,body)
	end
	
	#获取media的数量
	def self.get_media_sum(token)
		url='https://api.weixin.qq.com/cgi-bin/material/get_materialcount?access_token='+token
		ThridParty.get_to_wechat(url)
	end
	
	#获取media列表
	#参数  offset:跳过的个数
	#      count:获取的数量
	def self.get_media_list(token,type,offset,count)
		url='https://api.weixin.qq.com/cgi-bin/material/batchget_material?access_token='+token
		body='{"type":"'+type+'","offset":"'+offset+'","count":"'+count+'"}'
		ThirdParty.sent_to_wechat(url,body)
	end

	#根据group_id发送群发消息
	def self.sentall_by_group(token,is_to_all,group_id,type,array)
		url,body=return_url_body('group',token,['filter',is_to_all,group_id],type,array)
		ThirdParty.sent_to_wechat(url,body)
	end

	#根据openid发送群发消息
	def self.sentall_by_openid(token,arr_openid,type,array)
		url,body=return_url_body('openid',token,['touser',arr_openid],type,array)
		ThirdParty.sent_to_wechat(url,body)
	end

	def self.sentall_preview(token,openid,type,array)
		url,body=return_url_body('preview',token,['touser',openid],type,array)
		url='https://api.weixin.qq.com/cgi-bin/message/mass/preview?access_token='+token
		ThirdParty.sent_to_wechat(url,body)
	end
	
	def self.add_fake_data
			 imgs = CSV.read(Rails.root.join('public','wechatHeadImgList_160116-1557.csv'))
			 names = CSV.read(Rails.root.join('public','wechatNickNameList_160116-1756.csv'))
			 user_ids = [32,35,51,70,63,64,83,82]
			 1500.times.each do |index|
				name = names[names.size-1-index][0]
				if name.present?
						time=rand(1446307200..1452960000)
						member = Member.new
						member.del=2
						member.username=index
						member.created_at = Time.at(time)
						member.user_id = user_ids.sample
						if member.save
								wechat_config = WechatConfig.new
								wechat_config.del=2
								wechat_config.openid=index
								wechat_config.created_at=member.created_at
								wechat_config.member = member
								if wechat_config.save
											wechat_user = WechatUser.new
											wechat_user.wechat_config = wechat_config
											wechat_user.member = member
											wechat_user.nickname = name[name.size/2,name.size]
											wechat_user.sex = rand(0..1)
											wechat_user.headimgurl = imgs[imgs.size-1-index][0]
											wechat_user.subscribe_time = time
											wechat_user.created_at = member.created_at
											wechat_user.del=2
											wechat_user.save
								end
						end
				 end
			 end
	end


	def self.rm_fake_data
			Member.where(del:2).destroy_all
	end
	private
	 def self.return_url_body(by_what,token,first,type,array)
		if by_what=='group'
		   url='https://api.weixin.qq.com/cgi-bin/message/mass/sendall?access_token='+token
		   body='{"'+first[0]+'":{"is_to_all":'+first[1]+'"group_id":"'+first[2]+'"},"'
		else
		   url='https://api.weixin.qq.com/cgi-bin/message/mass/send?access_token='+token
		   if by_what=='preview'
		     body='{"'+first[0]+'":"'+first[1]+'","'
		   else
		     body='{"'+first[0]+'":'+first[1].inspect+',"'
	   	   end
		end
		if type=='mpvideo'
		   url1='https://api.weixin.qq.com/cgi-bin/media/uploadvideo?access_token='+token
                        body1='{"media_id":"'+array[1]+'","title":"'+array[2]+'","description":"'+array[3]+'"}'
                        array[1]=JSON.parse(ThirdParty.sent_to_wechat(url1,body1))['media_id']
		end
		body+=type+'":{"'+array[0]+'":"'+array[1]+'"},"msgtype":"'+type+'"}'	
		return url,body
	 end
end
