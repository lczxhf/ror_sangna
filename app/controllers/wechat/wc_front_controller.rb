class Wechat::WcFrontController < ApplicationController
			require "rexml/document" 
	before_action :check_openid,:except=>[:remark,:get_redbage,:page_technician,:project_class,:tip,:card_rule]
	before_action :set_sangna_config,:except=>[:remark,:get_redbage,:change_collect,:card_rule]
	include Wechat::WcFrontHelper
	def choose_technician
			puts params
			@inscene=false
			if @wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])	
				if @wechat_config.del==1 || params[:skip]=='h'
						if @qr_code=@wechat_config.member.per_user_qr_code
											@inscene=true
						end
				else
					redirect_to action: :tip,:appid=>params[:appid]
				end		
			end
	end

	def page_technician
			puts params
			@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
		 if params[:collect]=='true'	
				technician_ids=@sangna_config.per_user.masseuses_collects.where(member_id:@wechat_config.member.id,del:1).pluck(:per_user_masseuse_id)
				if technician_ids.empty?
							sql=''
				else
						sql="and b.del=1 and b.status=1 and b.id IN(#{technician_ids.join(',')}) and b.user_id=#{@sangna_config.per_user_id} "
					if params[:p_type]
							if params[:p_type]=='true'
								#technicians=@sangna_config.per_user.per_user_masseuses.where(job_class_status:params[:id]).active.where("id IN (#{technician_ids.join(',')})").limit(6).offset(6*(params[:page].to_i-1))		
								sql=sql+"and b.job_class_status=#{params[:id]}"
							else
								#technicians=@sangna_config.per_user.per_user_masseuses.where("projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'").active.where("id IN (#{technician_ids.join(',')})").limit(6).offset(6*(params[:page].to_i-1))
								sql=sql+"and b.projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'"
							end
					else
								#technicians=PerUserMasseuse.where("id in (#{technician_ids.join(',')})").active.limit(6).offset(6*(params[:page].to_i-1))
					end
				end
		 else
			 sql="and b.del=1 and b.status=1 and b.user_id=#{@sangna_config.per_user_id} "
			  if params[:p_type]
							if params[:p_type]=='true'
									#technicians=@sangna_config.per_user.per_user_masseuses.where(job_class_status:params[:id]).active.limit(6).offset(6*(params[:page].to_i-1))			
									sql=sql+"and b.job_class_status=#{params[:id]}"
							else
								#	technicians=@sangna_config.per_user.per_user_masseuses.where("projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'").active.limit(6).offset(6*(params[:page].to_i-1))
								sql=sql+"and b.projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'"
							end
				else
							#technicians=PerUserMasseuse.where(user_id:@sangna_config.per_user.id).active.limit(6).offset(6*(params[:page].to_i-1))
				end
		end
				if sql!=''
					mysql="select b.* from 
				(per_user_masseuses as b left join order_by_masseuses as a on a.masseuse_id=b.id) 
				left join per_user_projects as d on a.project_id=d.id
				 where (a.id=(select id from order_by_masseuses where masseuse_id=b.id and del=1 order by id desc limit 0,1 ) 
				  or (select count(*) from per_user_masseuses where masseuse_id=b.id)=0)
					#{sql}
				  order by abs(2.1-work_status) asc,DATE_ADD(a.created_at,INTERVAL d.duration MINUTE) asc
					limit #{6*(params[:page].to_i-1)},6"
					technicians=PerUserMasseuse.find_by_sql(mysql)
				else
					technicians=[]
				end
		  if !technicians.empty?
					arr=[]
					technicians.each do |technician|
							time=""
							if params[:inscene]=='true'
									if technician.work_status==3
											order=technician.order_by_masseuses.order(start_time: :desc).first	
											if order
													time=((order.start_time+order.per_user_project.duration.minutes).to_i-Time.now.to_i)/60
											else
													time=0
											end
									end
							end
							arr<<generate_technician_html(technician,params[:inscene],@sangna_config,time,@wechat_config.member_id)
					end
					render plain: arr.join
			else
				 render plain: ''
			end
	end
	def technician_info
		@technician=PerUserMasseuse.find(params[:t_id])
		@technician.details_page_times=@technician.details_page_times+1
		@technician.save
		@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])	
	end

	def search
	wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
	  if params[:is_mine]!='true'
			 sql="and b.del=1 and b.status=1 and b.user_id=#{@sangna_config.per_user_id} "
			if params[:p_type]
					if params[:p_type]=='true'
							#technicians=@sangna_config.per_user.per_user_masseuses.where(job_class_status:params[:id]).active.limit(6)		
							sql=sql+"and b.job_class_status=#{params[:id]}"
					else
							#technicians=@sangna_config.per_user.per_user_masseuses.where("projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'").active.limit(6)
							sql=sql+"and b.projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'"
					end
			else
					#technicians=@sangna_config.per_user.per_user_masseuses.where(job_number:params[:t_number]).active	
					sql=sql+"and b.job_number='#{params[:t_number]}'"
			end
		else
			collect=@sangna_config.per_user.masseuses_collects.where(member_id:wechat_config.member_id,del:1).pluck(:per_user_masseuse_id)
			if collect.empty?
						sql=''
			else
					sql="and b.del=1 and b.status=1 and b.user_id=#{@sangna_config.per_user_id} and b.id IN (#{collect.join(',')})"
					if params[:p_type]
							if params[:p_type]=='true'
									#technicians=@sangna_config.per_user.per_user_masseuses.where(job_class_status:params[:id]).active.where("id IN (#{collect.join(',')})").limit(6)		
									sql=sql+"and b.job_class_status=#{params[:id]}"
							else
									#technicians=@sangna_config.per_user.per_user_masseuses.where("projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'").where("id IN (#{collect.join(',')})").active.limit(6)
									sql=sql+"and b.projects_id regexp '(^|[^0-9])#{params[:id]}([^0-9]|$)'"
							end
					else
							#technicians=@sangna_config.per_user.per_user_masseuses.where(job_number:params[:t_number]).where("id IN (#{collect.join(',')})").active
							sql=sql+"and b.job_number='#{params[:t_number]}'"
					end
			end	
		end
			if sql!=''
			mysql="select b.* from 
				(per_user_masseuses as b left join order_by_masseuses as a on a.masseuse_id=b.id) 
				left join per_user_projects as d on a.project_id=d.id
				 where (a.id=(select id from order_by_masseuses where masseuse_id=b.id and del=1 order by id desc limit 0,1 ) 
				  or (select count(*) from per_user_masseuses where masseuse_id=b.id)=0)
					#{sql}
				  order by abs(2.1-work_status) asc,DATE_ADD(a.created_at,INTERVAL d.duration MINUTE) asc
					limit 0,6"
				technicians=PerUserMasseuse.find_by_sql(mysql)
			else
				technicians=[]
			end
				if !technicians.empty?
						string=technicians.collect do |technician|
								if params[:inscene]=='true'
									if technician.work_status==3
											order=technician.order_by_masseuses.order(start_time: :desc).first	
											if order
												time=((order.start_time+order.per_user_project.duration.minutes).to_i-Time.now.to_i)/60
											else
												time=0
											end
									else
											time=""	
									end
								end
										generate_technician_html(technician,params[:inscene],@sangna_config,time,wechat_config.member_id)
								end.join
						render plain: string 
				else
					 render plain: ''
				end
	end


	def technician_remark
					puts params
					@order=OrderByMasseuse.includes(:per_user_masseuse,:per_user_project,:per_user,member: [:wechat_config]).find(params[:o_id])
					if @order && @order.member.wechat_config.openid==cookies.signed["#{params[:appid]}_openid"]
							@sangna_config=@order.per_user.sangna_config
							@ab_status=PerUser.get_ab_status(@order.user_id)
							if params[:l]=='z'
								@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:2,del:1,status:1).first
								@open_redbage=true
							elsif params[:l]=="h"
								@open_redbage=false
							end
					else
								render nothing: true
					end
	end

	def technician_remark_level
				puts params
				@order=OrderByMasseuse.includes(:per_user_masseuse,:per_user,member: [:wechat_config]).find(params[:o_id])
					if @order &&  @order.member.wechat_config.openid==cookies.signed["#{params[:appid]}_openid"]
							@sangna_config=@order.per_user.sangna_config
							@ab_status=PerUser.get_ab_status(@order.user_id)
							if @order.technician_level_remarks.empty?
									@remark=false
							else
									@technician_level_remarks=@order.technician_level_remarks
									@remark=true
							end
							if params[:l]=='z'
								@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:2).first
								@open_redbage=true
							elsif params[:l]=="h"
								@open_redbage=false
							end
					else
								render nothing: true
					end
	end

	def recommend_technician
			technicians=@sangna_config.per_user.per_user_masseuses.active.where(work_status:2).order("rand()").limit(2)
			wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
			html=technicians.collect do |technician|
				if inscene=wechat_config.member.per_user_qr_code.present?
						if technician.work_status==3
							order=technician.order_by_masseuses.order(start_time: :desc).first	
							if order
								time=((order.start_time+order.per_user_project.duration.minutes).to_i-Time.now.to_i)/60
							else
								time=0
							end
						else
								time=""	
						end
				end
				generate_technician_html(technician,inscene.to_s,@sangna_config,time,wechat_config.member_id)
			end.join
			render plain: html
	end

	def project_info
			@projects=PerUserProject.where(user_id:@sangna_config.per_user.id,p_type:2).open
			Rails.cache.delete("#{params[:appid]}_openid")
	end

	def tip
			puts params
			if params[:user_id]
					check_openid
					@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
			else
				@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])	
				if !@wechat_config
					cookies.delete("#{params[:appid]}_openid")
					check_openid
				else
					params.delete(:controller)
					params.delete(:action)
				end
			end
	end

	def project_class
				projects=@sangna_config.per_user.per_user_projects.includes(type_relations: :per_user_project).where(p_type:1).open
				string=projects.collect do |a|
							"<div class='search_project'><button class='GongZhong' onclick=\"search_by_project('#{a.id}',true)\">#{a.name}</button>"+
							a.type_relations.collect {|b| "<button class='XiangMu' onclick=\"search_by_project('#{b.per_user_project.id}',false)\">#{b.per_user_project.name}</button>"}.join+"</div>"
				end.join
			render plain: string
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
				if @wechat_config.del==2
						redirect_to action: :tip,:appid=>params[:appid]
				end
				@wechat_user=@wechat_config.wechat_user
	end

	def my_collect
				
				@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				#technician_ids=@sangna_config.per_user.masseuses_collects.where(member_id:@wechat_config.member.id,del:1).pluck(:per_user_masseuse_id)
				#@technicians=PerUserMasseuse.find(technician_ids)
				@inscene=false
				if @qr_code=@wechat_config.member.per_user_qr_code
								@inscene=true
				else
								cookies["next_url"]=request.url
				end
	end

	def wifi_page
		wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
		if wechat_config.member.per_user_qr_code.present?
			@wifi_infos=PerUserWifi.where(user_id:@sangna_config.per_user_id,del:1)
		else
			@error_status=3
			render "/wechat/wc_front/wechat_error"		
		end
	end
	def redbage
				puts params
				#cookies.delete("#{params[:appid]}_openid")
				@order=OrderByMasseuse.includes(:member,:per_user).find(params[:o_id])				
				wechat_config=WechatConfig.includes(:wechat_user,:member).find_by_openid(cookies.signed["#{@order.per_user.sangna_config.appid}_openid"])
				if @order.member_id==params[:id].to_i
							if @order.member_id==wechat_config.member_id
									@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:2,same_id:params[:same]).first
							elsif wechat_config.try(:wechat_user).try(:subscribe_time)
									@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:3,same_id:params[:same]).first
							else
									@coupon_rule=@order.per_user.coupons_rules.where(name:'分享得红包',c_type:4,same_id:params[:same]).first
							end
							if wechat_config.member.username!=wechat_config.openid && wechat_config.member.username!='未关注'
								@bind=true
							else
								@bind=false
							end
				else
					render nothing: true
				end
				
	end

	def get_redbage
				puts params
				order=OrderByMasseuse.includes(:per_user_masseuse,per_user:[:sangna_config]).find(params[:o_id])
				wechat_config=WechatConfig.includes(:wechat_user,:member).find_by_openid(cookies.signed["#{order.per_user.sangna_config.appid}_openid"])
				member_id=wechat_config.member_id
				if CouponsRecord.find_by_sql("SELECT * FROM sangna.coupons_records as record left join coupons_classes as class on record.coupons_classes_id=class.id
 where from_order_id=#{order.id} and class.name='评价转发代金券' and member_id=#{member_id}").present?
						render plain: 'err'
				else
						status=1
						if order.member_id==member_id
							coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:2,same_id:params[:same]).first
							if order.qrcode_log.id!=wechat_config.member.qrcode_logs.order(created_at: :desc).first.id
									status=2
							end
						elsif wechat_config.wechat_user.subscribe_time.nil?
							coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:4,same_id:params[:same]).first
						else
							coupon_rule=order.per_user.coupons_rules.where(name:'分享得红包',c_type:3,same_id:params[:same]).first
						end
							coupon_record=coupon_rule.coupons_records.build
							o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
							string = (0...4).map{ o[rand(o.length)] }.join
							coupon_record.number=Time.now.to_i.to_s+string
							coupon_record.user_id=coupon_rule.user_id
							coupon_record.member_id=member_id
							coupon_record.coupons_class=CouponsClass.find(1) 
							coupon_record.created_at=Time.now
							coupon_record.value=coupon_rule.face_value
							coupon_record.from_order_id=params[:o_id]
							coupon_record.status=status
							coupon_record.save
							render plain: 'ok'
				end		
	end

def get_ab_redbage
		puts params
	order=OrderByMasseuse.find(params[:o_id])
	wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
	if !wechat_config.member.coupons_records.where(coupons_classes_id:2).where("status in (1,2)").first	
		if ab_rule=order.get_ab_rule
			if !CouponsRecord.where(member_id:wechat_config.member_id,from_order_id:order.id,coupons_classes_id:2).first
				if ab_rule.rules==1
					ab_recommended_projects=ab_rule.ab_recommended_projects.order("rand()").limit(1)
				elsif ab_rule.rules==2
					ab_recommended_projects=ab_rule.ab_recommended_projects
				end
				ab_recommended_projects.each do |a|
					coupons_record=CouponsRecord.new
					coupons_record.user_id=ab_rule.user_id
					coupons_record.member_id=wechat_config.member_id
					coupons_record.from_order_id=order.id
					o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
					string = (0...4).map{ o[rand(o.length)] }.join
					coupons_record.number=Time.now.to_i.to_s+string
					coupons_record.status=1
					coupons_record.projects_id=a.id
					coupons_record.value=a.value
					coupons_record.coupons_classes_id=ab_rule.coupons_classes_id
					coupons_record.save
				end
				render plain: ab_recommended_projects.size
			else
				render plain: 0
			end
		else
				render plain: 0
	    end
	else
		render plain: 0
	end
end

	def consumption_info
			puts params
			@coupons_records=CouponsRecord.includes(ab_recommended_project: :per_user_project).find(params[:card_ids].split(','))
	end
	def remark
					puts params
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

	def remark_level
		puts params
		order=OrderByMasseuse.where(id:params[:o_id],del:1,status:2,is_reviewed:1).first
			if order && order.technician_level_remarks.empty?
						new_params=params.deep_dup
						new_params.delete(:appid)
						new_params.delete(:controller)
						new_params.delete(:action)
						new_params.delete(:o_id)
						new_params.each do |a|
						technician_level=TechnicianLevel.find(a[0])
						if technician_level
							level=TechnicianLevelRemark.new
							level.technician_level=technician_level
							level.level=a[1].to_i
							level.order_by_masseuse=order
							level.per_user_masseuse=order.per_user_masseuse
							level.member_id=order.member_id
							level.save
						end
				end
				render plain: 'ok'
			else
				render plain: 'err'
			end
	end

	def change_collect
				wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				collect(params[:technician_id],wechat_config,params[:status])
				render plain: "success"	
	end

	def phone_bind
	end

	def card_info
				
				@wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{params[:appid]}_openid"])
				if @wechat_config.member.per_user_qr_code
						@inscene=true
				end
				if @wechat_config.member.username!=@wechat_config.openid && @wechat_config.member.username!='未关注'
						@bind=true
				end
				sql = ActiveRecord::Base.connection()  
				sql.update_sql 'update sangna.coupons_records as record left join coupons_rules as rule on record.coupons_rules_id=rule.id set record.status=4 where date_add(record.created_at,INTERVAL rule.due_day Day)<now() and member_id='+@wechat_config.member_id.to_s
				@cards=@sangna_config.per_user.coupons_records.includes(:coupons_rule).where(member_id:@wechat_config.member_id).order("abs(status-1.6) asc").order(created_at: :desc)
	end

	def card_rule
				if params[:rule_id]
					@card=CouponsRule.find(params[:rule_id]).coupons_records.build
				else
					@card=CouponsRecord.includes(:coupons_rule).find(params[:id])
				end
	end

	def use_card
			card=CouponsRecord.includes(:coupons_rule,:member).find(params[:c_id])
			if card.status==2
				  if card.created_at+card.coupons_rule.due_day.days<Time.now
							render plain: '代金券已过期'
					else
							card.status=3
							if card.save
								 	log=card.member.qrcode_logs.last	
									log.coupons_records<<card
									log.save
									card.sent_message(@sangna_config,card.member.wechat_config,log.per_user_qr_code.hand_code)
							end
							render plain: card.to_json(:include=>[:coupons_rule,:member=>{:include=>:per_user_qr_code}])
					end
			else
					render plain: '代金券不可用'
			end
	end

	def balance
	end

	def sent_code
		puts params
	 if params[:phone].length==11 && params[:phone].to_i.to_s.length==11
		 if !Member.where(username:params[:phone],user_id:@sangna_config.per_user_id).first
				 code=rand(1000..9999).to_s
				 uri = URI("http://106.ihuyi.cn/webservice/sms.php?method=Submit")
				 Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
				    request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
					  request.set_form_data({"account"=>"cf_zxy0506","password"=>"zxy0506","mobile"=>"#{params[:phone]}","content"=>"您的验证码是：#{code}。请不要把验证码泄露给其他人。如非本人操作，可不用理会！"})
						response=http.request request
						Rails.cache.write(params[:phone],code,:expire_in=>1.hour)
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
					 puts wechat_config.member.to_json
					 wechat_config.member.save
					 Rails.cache.delete(params[:phone])
					 render plain: 'ok'
			else
						render plain: 'err'
			end
	end

	private
	
	def check_openid
			if !cookies["#{params[:appid]}_openid"]	|| WechatConfig.find_by_openid(cookies.signed["#{params[:appid]}_openid"]).nil?
			cookies.signed[:next_url]=request.url
			auth_url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{params[:appid]}&redirect_uri=http://weixin.linkke.cn/wechat/gzh_manage/oauth&response_type=code&scope=snsapi_base&state=123&component_appid=wxf6a05c0e64bc48e1#wechat_redirect"                    
		   redirect_to auth_url
			end
	end

	def set_sangna_config
			if params[:appid]
					Rails.cache.delete(params[:appid])
					@sangna_config=Rails.cache.fetch(params[:appid],expire_in: 2.hours) do 
							SangnaConfig.includes(per_user:[:per_user_imgs]).find_by_appid(params[:appid])
					end
			end
	end

	def generate_technician_html(technician,inscene,sangna_config,time,member_id)
			%{	<div class="Jishi_infor jishi_color" onclick="show_info('#{technician.id}')">
					<div class="box_jishi">
						<div class="box_img jishi_background">
							<img class="jishi_img" src="#{technician.get_image(member_id)}" alt="" height="50px" width="50px" />
						</div>
			}+	if technician.seniority
				%{
						<div class="box_seniority">
							<span class="seniority_num">#{technician.seniority}</span>
							<span class="seniority_Company">年</span>
						</div>
				}
				else
					""
				end
			+%{
						<div class="JiShi_JobNum">
							<span class="jishi_num fs17">#{technician.job_number}</span>
							<span class="jishi_sex fs11">（#{technician.sex==1 ? "男":"女"}）</span>
						</div>
						<span class="jishi_type">#{technician.per_user_project.try(:name)}</span>

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
									if appointment=technician.appointments.where(status:1).order(service_time: :asc).limit(1).first
											'<span class="current_state fs12"> <span class="time">在'+appointment.service_time.strftime("%H:%M")+'</span>有约</span>'
									else
											'<span class="current_state fs12"> <span class="time"></span></span>'
									end
							else
								if technician.masseuses_work_shift
								"<span class='current_state fs12'>在场时间:#{technician.masseuses_work_shift.start_time.try(:strftime,"%H:%M")}-#{technician.masseuses_work_shift.end_time.try(:strftime,"%H:%M")}</span>"		
								else
										" "
								end
							end+"</div></div>"
			
	end
	def collect(t_id,wechat_config,status='add')
				technician=PerUserMasseuse.find(t_id)
			  collect=MasseusesCollect.find_or_initialize_by(per_user_masseuse_id:technician.id,member_id:wechat_config.member.id,per_user_id:wechat_config.member.user_id)
				if status=="add"
						collect.del=1
				else
					  collect.del=2	
				end
				collect.save
	end
end
