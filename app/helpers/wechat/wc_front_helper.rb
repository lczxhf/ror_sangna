module Wechat::WcFrontHelper
	def return_job_class(number,is_zh=true)
		job_class=[0,["Dating","大厅技师"],["Fangjian","房间技师"],["Meirong","美容技师"]]
		if is_zh
			return job_class[number][1]
		else
			return job_class[number][0]
		end
	end

	def return_technician_state(number)
		state=[0,"下班","空闲","上锁","上钟"]
		state[number]
	end

	def get_hot_project(technician_id)
		arr=MasseusesReview.where(masseuses_id:technician_id).pluck(:best_project_id)
		if arr.empty?
			"无"
	  else
			index=reckon_most(arr)
			PerUserProject.pluck(:name).find(arr[index]).first
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
			TechniqueEvalution.pluck(:name).find(arr[index]).first
		end
	end

	def get_language_name(number)
			language_arr=[0,"粤语","中文","英语"]
			language=[]
			number.split(',').each do |a|
					language<<language_arr[a.to_i]
			end
		language.join(',')
	end

	def get_review_rate(technician_id)
		level_arr=MasseusesReview.where(masseuses_id:technician_id).pluck(:star_level)
		if level_arr.empty?
			false 	
		else
		  @level_rate=((level_arr.inject{|a,b| a+b}).to_f/(level_arr.size*5).to_f)*100
		end
	end

	def is_collect(technician_id)
			wechat_config=WechatConfig.includes(:member).find_by_openid(cookies[:openid])
			member_id=wechat_config.member.id
			if MasseusesCollect.where(per_user_masseuse_id:technician_id,member_id:member_id).exist?
					'man'
			else
					'kong'
			end
	end
end
