class Tech::RegisterController < ApplicationController
	def register
		# puts session[:code]
		tel_code = Rails.cache.read(tel)
		register = PerUserMasseuse.new
		register.username = params[:user] 
		register.password = params[:pwd]
		club = PerUser.find_by(poll_code: params[:club_code])
        register.user_id = club.id
        verify = params[:verify]
        if verify != tel_code
       		render plain: '验证码错误'
        else
        	register.save
        end
		render nothing:true
	end

	def verify
		verify = rand(9999)
		# puts params[:user]
		tel =  params[:user]
		Rails.cache.write(tel,verify)
		session[:code] = verify
         uri = URI("http://106.ihuyi.cn/webservice/sms.php?method=Submit")
         Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
         	request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
         	request.set_form_data({"account"=>"cf_zxy0506","password"=>"zxy0506","mobile"=>"#{tel}","content"=>"您的验证码是：#{verify}。请不要把验证码泄露给其他人。如非本人操作，可不用理会！"})
         	response=http.request request
         	puts  response.body
         end
        # render plain: 'ok'
		render nothing:true
	end

	def project
		projects = PerUserProject.select('id,name').where(user_id: params[:user_id])

		render json: projects
	end

	def upload
		upload = PerUserMasseuse.find(147)
		upload.img = params[:uploadkey1]
		puts 1111
		puts params[:uploadkey1]
		puts 1111
		upload.save
		render nothing:true
	end

	def up
	end

end
