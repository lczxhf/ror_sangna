class Tech::RegisterController < ApplicationController
	def register
		tel =  params[:user]
		tel_code = Rails.cache.read(tel)
		register = PerUserMasseuse.new
		register.username = params[:user] 
		register.password = params[:pwd]
		club = PerUser.find_by(poll_code: params[:club_code])
        register.user_id = club.id
        verify = params[:verify]
      #   user = PerUserMasseuse.where(username: tel).first
      #   if user

      #   		render plain: '用户名已经存在'
	     # else
	        
	     	if verify != tel_code
	       		render plain: '验证码错误'
	    	else
	        	register.save
	        	render plain: 'ok'
	        end
        # end
        
		
	end

	def verify
		verify = rand(9999).to_s
		tel =  params[:user]
		user = PerUserMasseuse.where(username: tel).first
		if user.username
			render plain: '用户名已经存在'
		else
			 Rails.cache.write(tel,verify)
	         uri = URI("http://106.ihuyi.cn/webservice/sms.php?method=Submit")
	         Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
	         	request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
	         	request.set_form_data({"account"=>"cf_zxy0506","password"=>"zxy0506","mobile"=>"#{tel}","content"=>"您的验证码是：#{verify}。请不要把验证码泄露给其他人。如非本人操作，可不用理会！"})
	         	response=http.request request
	         	puts  response.body
	         end
		end	
		
		
	end

	def project
		projects = PerUserProject.select('id,name').where(user_id: params[:user_id])

		render json: projects
		# render nothing:true
	end


	def upload
		upload = PerUserMasseuse.find(177)
		upload.img = params[:uploadkey1]
		upload.entry_time = params[:entry]
		upload.name = params[:name]
		upload.address = params[:address]
		upload.sex = params[:sex]
		upload.job_class_status = params[:type]
		upload.identification_numbers = params[:ident]
		render nothing:true
	end

	def up
	end

end
