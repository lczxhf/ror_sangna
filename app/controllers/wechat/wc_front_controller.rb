class Wechat::WcFrontController < ApplicationController
			require "rexml/document" 
	before_action :check_openid,:except=>[:remark,:get_redbage,:page_technician]
	before_action :set_sangna_config,:except=>[:remark,:get_redbage]
	include Wechat::WcFrontHelper
	def choose_technician
		#@technicians=PerUserMasseuse.where(user_id:@sangna_config.per_user.id).limit(5).offset(5*(page-1))
			@inscene=false
			if @wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])	
				 if @wechat_config.member.hand_code	
						if @qr_code=PerUserQrCode.includes(:user_qr_code_rule).where(user_id:@sangna_config.per_user.id,hand_code:@wechat_config.member.hand_code).first
								@inscene=true
						end
				 end
			end
	end

	def page_technician
		 if params[:collect]=='true'	
				@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				technician_ids=@sangna_config.per_user.masseuses_collects.where(member_id:@wechat_config.member.id,del:1).limit(6).offset(6*(params[:page].to_i-1)).pluck(:per_user_masseuse_id)
				technicians=PerUserMasseuse.find(technician_ids)
		 else
			technicians=PerUserMasseuse.where(user_id:@sangna_config.per_user.id).limit(6).offset(6*(params[:page].to_i-1))
			end
			arr=[]
			technicians.each do |technician|
			time=""
			if params[:inscene]=='true'
					if technician.work_status==3
							order=technician.order_by_masseuses.order(start_time: :desc).first	
							time=((order.start_time+order.per_user_project.duration.minutes).to_i-Time.now.to_i)/60
					end
			end
					arr<<generate_technician_html(technician,params[:inscene],@sangna_config,time)
			end
			render plain: arr.join
	end
	def technician_info
		@technician=PerUserMasseuse.find(params[:t_id])
	end

	def search
			technician=@sangna_config.per_user.per_user_masseuses.find_by_job_number(params[:t_number])	
				if technician
					time=''
						if params[:inscene]=='true'
							if technician.work_status==3
								order=technician.order_by_masseuses.order(start_time: :desc).first	
								time=((order.start_time+order.per_user_project.duration.minutes).to_i-Time.now.to_i)/60
							end
						end
					if params[:is_mine]=='true'
						wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
						collect=@sangna_config.per_user.masseuses_collects.includes(:per_user_masseuse).where(member_id:wechat_config.member_id,del:1,per_user_masseuse_id:technician.id).first
						if collect
								render plain: generate_technician_html(technician,params[:inscene],@sangna_config,time)
						else
								render plain: 'uncollect'
						end
					else
						render plain: generate_technician_html(technician,params[:inscene],@sangna_config,time)
					end
				else
					 render plain: ''
				end
	end

	def technician_remark
					@order=OrderByMasseuse.includes(:per_user_masseuse,:per_user,member: [:wechat_config]).find(params[:o_id])
					if @order.member.wechat_config.openid==cookies.signed["#{params[:appid]}_openid"]
								@sangna_config=@order.per_user.sangna_config
								@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:2).first
					else
								render nothing: true
					end
	end

	def project_info
			@projects=PerUserProject.where(user_id:@sangna_config.per_user.id)
	end

	def project_detail
			@project=PerUserProject.find(params[:p_id])
	end

	def sangna_info
			@sangna=@sangna_config.per_user
			if @sangna.status==1&&@sangna.del==1
				@per_user_imgs=@sangna.per_user_imgs
				@sangna_info=@sangna.per_user_info
			else
				render plain: "该会所暂时无法查看"
			end
	end

	def my_account
				@wechat_config=WechatConfig.includes(:wechat_user,:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"]) 
				
				@wechat_user=@wechat_config.wechat_user
	end

	def my_collect
				
				@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				#technician_ids=@sangna_config.per_user.masseuses_collects.where(member_id:@wechat_config.member.id,del:1).pluck(:per_user_masseuse_id)
				#@technicians=PerUserMasseuse.find(technician_ids)
				@inscene=false
				 if @wechat_config.member.hand_code	
						if @qr_code=PerUserQrCode.includes(:user_qr_code_rule).where(user_id:@sangna_config.per_user.id,hand_code:@wechat_config.member.hand_code).first
								@inscene=true
						else
								cookies["next_url"]=request.url
						end
			 end
	end

	def redbage
				#cookies.delete("#{params[:appid]}_openid")
				@order=OrderByMasseuse.includes(:member,:per_user).find(params[:o_id])				
				wechat_config=WechatConfig.includes(:wechat_user).find_by_openid(cookies.signed["#{@order.per_user.sangna_config.appid}_openid"])
				if @order.member_id==params[:id].to_i
						if @order.member_id==wechat_config.member_id
							@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:2).first
						elsif wechat_config.wechat_user.subscribe_time.nil?
							@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:4).first
						else
							@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:3).first
						end
						render :redbage
				else
						render nothing: true
				end
	end

	def get_redbage
				order=OrderByMasseuse.includes(per_user:[:sangna_config]).find(params[:o_id])
				wechat_config=WechatConfig.includes(:wechat_user).find_by_openid(cookies.signed["#{order.per_user.sangna_config.appid}_openid"])
				member_id=wechat_config.member_id
				if order.coupons_records.find_by_member_id(member_id)
						render plain: 'err'
				else
						if order.member_id==member_id
							coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:2).first
						elsif wechat_config.wechat_user.subscribe_time.nil?
							coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:4).first
						else
							coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:3).first
						end
							coupon_record=coupon_rule.coupons_records.build
							o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
							string = (0...4).map{ o[rand(o.length)] }.join
							coupon_record.number=Time.now.to_i.to_s+string
							coupon_record.user_id=coupon_rule.user_id
							coupon_record.member_id=member_id 
							coupon_record.created_at=Time.now
							coupon_record.order_id=params[:o_id]
							coupon_record.save
							render plain: 'ok'
				end		
	end

	def remark
					order=OrderByMasseuse.where(id:params[:o_id],del:1,status:2,is_reviewed:1).first
					if order
						masseuse_review=MasseusesReview.new
						masseuse_review.user_id=order.user_id
						masseuse_review.masseuses_id=order.masseuse_id
						masseuse_review.member_id=order.member_id
						masseuse_review.technique_evalution_id=params[:remark].to_i
						masseuse_review.order_id=order.id
						masseuse_review.save
						order.is_reviewed=2
						order.save
						render plain: 'ok'
					else
						render plain: 'err'
					end
	end

	def change_collect
				puts params
				technician=PerUserMasseuse.find(params[:technician_id])
				wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				
			  collect=MasseusesCollect.find_or_initialize_by(per_user_masseuse_id:technician.id,member_id:wechat_config.member.id,per_user_id:@sangna_config.per_user.id)
				if params[:status]=="add"
						collect.del=1
				else
					  collect.del=2	
				end
				collect.save
				render plain: "success"	
	end

	def phone_bind
	end

	def card_info
				
				wechat_config=WechatConfig.find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				if wechat_config.member.hand_code	
						if qr_code=PerUserQrCode.includes(:user_qr_code_rule).where(user_id:@sangna_config.per_user.id,hand_code:wechat_config.member.hand_code).first
								@inscene=true
						end
				 end

				@cards=@sangna_config.per_user.coupons_records.includes(:coupons_rule).where(member_id:wechat_config.member_id).order(:status)
	end

	def use_card
			card=CouponsRecord.includes(:coupons_rule,:member).find(params[:c_id])
			puts card.to_json
			if card.status==2
				  if card.created_at+card.coupons_rule.due_day.days<Time.now
							render plain: '代金券已过期'
					else
							card.status=3
							card.save
							render plain: card.to_json(:include=>[:member,:coupons_rule])
					end
			else
					render plain: '代金券不可用'
			end
	end

	def balance
	end

	def sent_code
	 if params[:phone].length==11 && params[:phone].to_i.to_s.length==11
		 if !Member.find_by_username(params[:phone])
				 code=rand(1000..9999).to_s
				 Rails.cache.write(params[:phone],code,:expire_in=>1.hour)
				 uri = URI("http://106.ihuyi.cn/webservice/sms.php?method=Submit")
				 Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
				    request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
					  request.set_form_data({"account"=>"cf_zxy0506","password"=>"zxy0506","mobile"=>"#{params[:phone]}","content"=>"您的验证码是：#{code}。请不要把验证码泄露给其他人。如非本人操作，可不用理会！"})
						response=http.request request
						a=response.body.dup
						puts a
						 result= REXML::Document.new a
						 render plain:  result.root.get_elements('msg')[0][0].to_s
				end
	   else
					render plain: 'exist'
	   end
	 else
					render plain: 'err'
	 end
	end


	def bind_phone
		  if params[:code]==Rails.cache.read(params[:phone])
					 wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
					 wechat_config.member.username=params[:phone]
					 wechat_config.member.save
					 render plain: 'ok'
			else
						render plain: 'err'
			end
	end

	private
	
	def check_openid
			if !cookies["#{params[:appid]}_openid"]							
			cookies.signed[:next_url]=request.url
			auth_url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{params[:appid]}&redirect_uri=http://weixin.linkke.cn/wechat/gzh_manage/oauth&response_type=code&scope=snsapi_base&state=123&component_appid=wxf6a05c0e64bc48e1#wechat_redirect"                    
		   redirect_to auth_url
			end
	end

	def set_sangna_config
			if params[:appid]
					@sangna_config=Rails.cache.fetch(params[:appid],expire_in: 4.hours) do 
							SangnaConfig.includes(per_user:[:per_user_imgs]).find_by_appid(params[:appid])
					end
			end
	end

	def generate_technician_html(technician,inscene,sangna_config,time)
			%{	<div class="Jishi_infor jishi_color" onclick="show_info('#{technician.id}')">
					<div class="box_jishi">
						<div class="box_img jishi_background">
							<img class="jishi_img" src="#{technician.img.normal.url}" alt="" height="50px" width="50px" />
						</div>
						<span class="jishi_num fs17">#{technician.job_number}</span>
						<span class="jishi_sex fs11">（#{technician.sex==1 ? "男":"女"}）</span>
						<span class="jishi_type">#{return_job_class(technician.job_class_status)}</span>

			}+if inscene=='true'
						if technician.work_status==1
							"<span class='waiting'>待</span>"
						elsif technician.work_status==2
							"<div><span class='spare'>闲</span></div>"
						elsif technician.work_status==3
							"<div><div class='box_busy'><span class='busy'>忙</span><div class='surplus_time'>#{time}分钟后空闲</div></div></div>"
						end
			  else
						%{		<a href="tel:#{sangna_config.per_user.phone}">
									<div class="yuan_yuyue">
										<span class="mui-icon mui-icon-phone"></span>
										<!--<span class="mui-icon iconfont icon-dianhua"></span>  --!>
									</div>
								</a>
								<div class="yuan_shoucang">
									<!--	<span class="mui-icon iconfont icon-xingxingman"> </span>  --!>
									<span class="mui-icon iconfont icon-xingxing#{is_collect(sangna_config.appid,technician.id)}" onclick="collect('#{technician.id}',this)"></span> 
								</div>
						}		
			  end+ %{
						</div>
						<div class="evaluate fs12">
							最多人评价：
							<!--			<span class="project"></span>   --!>
							<span class="jishi_best">#{get_hot_comment(technician.id)}</span>
					}+	if inscene=='true'
							'<span class="current_state fs12"> <span class="time">在13:00</span>有约</span>'
							else
								"<span class='current_state fs12'>在场时间:#{technician.work_time_start.try(:localtime).try(:strftime,"%H:%M")}-#{technician.work_time_end.try(:localtime).try(:strftime,"%H:%M")}</span>"
							end+"</div></div>"
			
	end
end
