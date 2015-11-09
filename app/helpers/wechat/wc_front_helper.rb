module Wechat::WcFrontHelper
	 def fetch_redis(key,expire_in=7000,&block)
         result=$redis.get(key)
         if result.nil?
            puts "#{key} cache invaild"
            result=Marshal.dump(yield)
            $redis.set(key,result,ex:expire_in)
         end
         Marshal.load(result)
     end
	def return_job_class(number,is_zh=true)
		job_class=[0,["Dating","大厅"],["Fangjian","房间"],["Meirong","美容"]]
		if number
			if is_zh
				return job_class[number][1]
			else
				return job_class[number][0]
			end
		else
				return '技师'
		end
	end

	def return_technician_state(number)
		state=[0,"已经下班","空闲","分钟后有空","上钟"]
		state[number]
	end

	def get_hot_project(technician_id)
		arr=MasseusesReview.where(masseuses_id:technician_id).pluck(:best_project_id)
		if arr.empty?
			"无"
	  else
			index=reckon_most(arr)
			PerUserProject.find(arr[index]).name
		end
	end

	def reckon_most(arr)
		middle_arr=[]
		middle_sum=[]
		arr.each do |a|
			if index=middle_arr.index(a)
				middle_sum[index]+=1
			else
				middle_arr<<a
				middle_sum<<1
			end
		end

		middle_value=0
		middle_sum.each do |sum|
			middle_value=sum if sum>middle_value
		end
		middle_sum.index(middle_value)
	end
	def get_hot_comment(technician_id)
		arr=MasseusesReview.where(masseuses_id:technician_id).pluck(:technique_evalution_id)
		if arr.empty?
			"无"
		else
			index=reckon_most(arr)
			TechniqueEvalution.find(arr[index]).name
		end
	end

	def get_hand_code_sex(number)
			arr=[0,'男宾','女宾','锁牌']
			arr[number]
	end

	def get_language_name(number)
			language_arr=[0,"粤语","普通话","英语"]
			language=[]
			number.split(',').each do |a|
					language<<language_arr[a.to_i]
			end
		language.join(',')
	end

	def get_review_rate(technician_id,level_id)
		level_arr=TechnicianLevelRemark.where(per_user_masseuse_id:technician_id,technician_level_id:level_id,del:1).pluck(:level)
		if level_arr.empty?
		"暂无评论"	
		else
			a=level_arr.sum.to_f
			b=level_arr.size.to_f
			(a/b).to_s(:rounded,precision:1)
		end
	end

	def is_collect(appid,technician_id)
			wechat_config=WechatConfig.includes(:member).find_by_openid(cookies.signed["#{appid}_openid"])
			member_id=wechat_config.member.id
			if MasseusesCollect.where(per_user_masseuse_id:technician_id,member_id:member_id,del:1).exists?
					'man'
			else
					'kong'
			end
	end


	def signature(timestamp,noncestr)
			if !Rails.cache.read("#{params[:appid]}_ticket")
						if Time.now-@sangna_config.updated_at>=6000
              result=JSON.parse(ThirdParty.refresh_gzh_token(Rails.cache.read(:access_token),'wxf6a05c0e64bc48e1',@sangna_config.appid,@sangna_config.refresh_token))
							if result['authorizer_refresh_token']
              @sangna_config.refresh_token=result['authorizer_refresh_token']
              @sangna_config.token=result['authorizer_access_token']
              @sangna_config.save
              $redis.del(@sangna_config.appid)
							end
						end					
						url="https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{@sangna_config.token}&type=jsapi"
						ticket=JSON.parse(ThirdParty.get_to_wechat(url))["ticket"]
						Rails.cache.write("#{params[:appid]}_ticket",ticket,:expires_in=>7200)
			end
			query={	
				timestamp: timestamp,
				noncestr: noncestr,
				url: request.url,
			  jsapi_ticket: Rails.cache.read("#{params[:appid]}_ticket")
			}.sort.collect do |key, value|
								"#{key}=#{value}"
				     end.join('&')
			Digest::SHA1.hexdigest(query)
	end
end
