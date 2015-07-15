class Wechat::MessageController < ApplicationController
  require 'net/http'
  require "nokogiri"
  include Wechat::ReplyWeixinMessageHelper
  TOKEN='tiandiwang'
  KEY="IuvWqPHol3TrXsLYMuOKisVFjewCwIUJBJ6ucMBKjp8"
  APPID="wxf6a05c0e64bc48e1"
  APPSECRET="0c79e1fa963cd80cc0be99b20a18faeb"
  def receive
		gzh=SangnaConfig.where(appid:params[:appid]).first
		str=request.body.read
		doc=Nokogiri::Slop str
		encrypt=doc.xml.Encrypt.content
		if ThirdParty.check_info(TOKEN,params[:timestamp],params[:nonce],encrypt,params[:msg_signature])
			result=ThirdParty.new.decrypt(encrypt,KEY,APPID)		
			puts result
			xml=Nokogiri::Slop result
			hash={}
			xml.xml.css('*').each do |a|
			    hash[a.node_name]=a.content
			end
			@weixin_message=Message.factory hash
			if @weixin_message.MsgType=='event'
			    if @weixin_message.Event=='subscribe'
							
							wechat_config=WechatConfig.find_or_create_by(openid:@weixin_message.FromUserName,sangna_config_id: gzh.id)
							wechat_config.del=1
							if !wechat_config.member
									member=Member.create(user_id:gzh.per_user.id,username:wechat_config.openid)
									wechat_config.member=member
									wechat_config.save
							end
			    	Sangna.get_user_info(wechat_config.id,APPID)
					render xml: reply_news_message([generate_article("欢迎您关注#{gzh.per_user.name}会所","立即开始查看我们的技师实时状态，选择您喜欢的技师！","http://weixin.linkke.cn/images/subscribe.png","http://weixin.linkke.cn/wechat/wc_front/choose_technician?appid=#{gzh.appid}")])	
			    else
							wechat_config=WechatConfig.includes(:wechat_user).find_by_openid(@weixin_message.FromUserName)
							wechat_config.del=2
							wechat_config.wechat_user.del=2
							wechat_config.save
							wechat_config.wechat_user.save
			    end
			elsif @weixin_message.MsgType=='text'
				if @weixin_message.Content=='pay'
				abc='http://shop.29mins.com/test_pay/pay?openid='+@weixin_message.FromUserName+'&showwxpaytitle=1'
				elsif @weixin_message.Content=="qrpay"
				abc='http://shop.29mins.com/test_pay/pay?type=qrcode&product_id='+SecureRandom.hex(12)
				else
						abc='test'
				end
				render xml: reply_text_message(abc)	
			else
				render xml: reply_text_message("other") 
			end
		end
   end
end
