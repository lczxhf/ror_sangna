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
		state=[0,"不当值","空闲","上锁","上钟"]
		state[number]
	end

	def get_hot_project(technician_id)
		arr=MasseusesReview.where(masseuses_id:technician_id).pluck(:best_project_id)

		index=reckon_most(arr)
		PerUserProject.find(project_arr[index]).pluck(:name)
	end

	def reckon_most(arr)
		middle_arr=[]
		middle_sum=[]
		arr.each do |a|
			if index=middle_arr.index(a)
				middle_sum[index]+=1
			else
				middle_arr<<a
				middle_sum<<0
			end
		end

		middle_value=0
		middle_sum.each do |sum|
			middle_value=sum if sum>middle_value
		end
		middle_value.index(middle_value)
	end
	def get_hot_conment(technician_id)
		arr=MasseusesReview.where(masseuses_id:technician_id).pluck(:technique_evalution_id)

		index=reckon_most(arr)
		TechniqueEvalution.find(project_arr[index]).pluck(:name)
	end
end
