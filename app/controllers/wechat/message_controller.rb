class Wechat::MessageController < ApplicationController
  require 'net/http'
  require "nokogiri"
  include Wechat::ReplyWeixinMessageHelper
	include Wechat::WcFrontHelper
  TOKEN='tiandiwang'
  KEY="IuvWqPHol3TrXsLYMuOKisVFjewCwIUJBJ6ucMBKjp8"
  APPID="wxf6a05c0e64bc48e1"
  APPSECRET="0c79e1fa963cd80cc0be99b20a18faeb"
  def receive
		gzh=fetch_redis(params[:appid],4500) do
            SangnaConfig.find_by_appid(params[:appid])
        end

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
							wechat_config=WechatConfig.find_or_initialize_by(openid:@weixin_message.FromUserName,sangna_config_id: gzh.id)
							wechat_config.del=1
							if !wechat_config.member
									member=Member.new(user_id:gzh.per_user.id,username:wechat_config.openid)
									wechat_config.member=member
							end
							if qrcode=Rails.cache.read("#{@weixin_message.FromUserName}_entrance")
								if gzh.per_user.on_off_dupy_auth == 3
									simplest_enter(qrcode,wechat_config,gzh.per_user)
								else
									entry(wechat_config,qrcode,gzh.per_user)
								end
								Rails.cache.delete("#{@weixin_message.FromUserName}_entrance")
								Rails.cache.delete("#{qrcode}_entrance")
							end
							wechat_config.member.save
							wechat_config.save
			    	Sangna.get_user_info(wechat_config.id,APPID)
						puts 'prepare sent subscribe message'
					render xml: reply_news_message([generate_article("海量技师任你挑","技师图片,技师状态,技师评价","http://weixin.linkke.cn/images/subscribe.png","http://weixin.linkke.cn/wechat/wc_front/choose_technician?appid=#{gzh.appid}")])	
			    elsif @weixin_message.Event=='unsubscribe'
							wechat_config=WechatConfig.includes(:wechat_user).find_by_openid(@weixin_message.FromUserName)
							wechat_config.del=2
							wechat_config.wechat_user.del=2
							wechat_config.save
							wechat_config.wechat_user.save
							if wechat_config.member.per_user.id.in?([31,39])
									wechat_config.member.destroy
									$redis.del(wechat_config.openid)
							end
							render plain: ''
					elsif @weixin_message.Event=='SCAN'
							render plain: "success"
					else
							render plain: ''
			    end
			elsif @weixin_message.MsgType=='text'
				if @weixin_message.Content=='pay'
				abc='http://shop.29mins.com/test_pay/pay?openid='+@weixin_message.FromUserName+'&showwxpaytitle=1'
				elsif @weixin_message.Content=="qrpay"
				abc='http://shop.29mins.com/test_pay/pay?type=qrcode&product_id='+SecureRandom.hex(12)
				elsif @weixin_message.Content=='TESTCOMPONENT_MSG_TYPE_TEXT'
						abc='TESTCOMPONENT_MSG_TYPE_TEXT_callback'
				elsif @weixin_message.Content.include?('QUERY_AUTH_CODE')
				url="https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token="+Rails.cache.read(:access_token)
				body='{"component_appid":"'+APPID+'","authorization_code":"'+@weixin_message.Content.gsub('QUERY_AUTH_CODE:',"")+'"}'
				a=JSON.parse(ThirdParty.sent_to_wechat(url,body))
				 url1="https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token="+a['authorization_info']['authorizer_access_token']
				 body1='{"touser":"'+@weixin_message.FromUserName+'","msgtype":"text","text":{"content":"'+@weixin_message.Content.gsub('QUERY_AUTH_CODE:',"")+'_from_api"}}'
				 puts result= ThirdParty.sent_to_wechat(url1,body1)

							abc=''
				else
						abc=@weixin_message.Content
				end
				render xml: reply_text_message(abc)	
			else
				render xml: reply_text_message("other") 
			end
		end
   end

   private

   def entry(wechat_config,qrcode,per_user)
   							qrcode=PerUserQrCode.find(qrcode)
							log=qrcode.qrcode_logs.where(status:2).first
							if log.present?
								if log.member.nil?
									log.member=wechat_config.member
									log.member_bind_time=Time.now
									coupons_records=wechat_config.member.coupons_records.where("status in (1,2)")
									log.entrance_card_count=coupons_records.size
									log.entrance_card_sum= coupons_records.collect{|a| a.value}.sum
									log.save
									wechat_config.member.hand_code=qrcode.id
									wechat_config.member.save
									if !coupons_records.empty?
										sql=ActiveRecord::Base.connection.execute("update coupons_records set status=2 where id in (#{coupons_records.collect{|a| a.id}.join(',')})")
									end
									SentWifiMessage.perform_in(30.seconds,per_user.id,wechat_config.openid)
								end
						end
   end
   		def simplest_enter(qrcode,wechat_config,per_user)
   			qrcode=PerUserQrCode.find(qrcode)
         log = QrcodeLog.new
         log.per_user_qr_code = qrcode
         log.status = 2
         log.per_user = per_user
         log.member = wechat_config.member
         log.member_bind_time = Time.now
         coupons_records=wechat_config.member.coupons_records.where("status in (1,2)")
         log.entrance_card_count=coupons_records.size
         log.entrance_card_sum= coupons_records.collect{|a| a.value}.sum
         log.save
         wechat_config.member.hand_code=qrcode.id
         wechat_config.member.save
         unvalid_cards=coupons_records.collect do |a|
             if a.status == 1
                   if Time.now - (a.created_at + 1.day) >= 0
                         a.id
                   else
                        nil
                   end
             else
                   nil
             end
         end.compact
         if !unvalid_cards.empty?
         CouponsRecord.where("id in (#{unvalid_cards.join(',')})").update_all(status:2)
     	 end
     	 SentEnterCard.perform_async(wechat_config.member_id,per_user.id,log.id,wechat_config.openid)
     	 AutoUnbind.perform_in(per_user.approach_time_setting.minutes,wechat_config.member_id)
     	 SentWifiMessage.perform_in(30.seconds,per_user.id,wechat_config.openid)
     	 
		end
end
