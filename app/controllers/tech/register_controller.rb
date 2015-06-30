class Tech::RegisterController < ApplicationController
	def register
		tel =  params[:user]
		tel_code = Rails.cache.read(tel)
		register = PerUserMasseuse.new
		register.username = tel
		register.pwd = params[:pwd]
		club = PerUser.find_by(poll_code: params[:club_code])
        register.user_id = club.id
        verify = params[:verify]
        user = PerUserMasseuse.where(username: tel).first
        if user
        		render plain: '用户名已经存在'
	     else
	        
	     	if verify != tel_code
	       		render plain: '验证码错误'
	    	else
	        	register.save
	        	registers = PerUserMasseuse.select('id','user_id').where(username: tel)
	        	render json: registers 
	        end
        end
        
		
	end

	def verify
		verify = rand(1000..9999).to_s
		tel =  params[:user]
		user = PerUserMasseuse.where(username: tel).first
		if user
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
	         render nothing:true
		end	
		
		
	end

	def project
		projects = PerUserProject.select('id,name').where(user_id: params[:user_id])

		render json: projects
		# render nothing:true
	end


	def upload
		upload = PerUserMasseuse.find(params[:tech_id])
		upload.img = params[:uploadkey1]
		upload.entry_time = params[:entry]
		upload.name = params[:name]
		upload.address = params[:address]
		upload.sex = params[:sex]
		upload.job_class_status = params[:type]
		upload.identification_numbers = params[:ident]
		upload.language = params[:language]
    upload.client_id = params[:cid]
		if upload.save
			render plain: 'ok'
    else
		  render nothing:true
		end
	end

	def up
	end

  def login
    user = params[:user]
    pwd = params[:pwd]
    login = PerUserMasseuse.authenticate_mobile(user, pwd)
    if login
      render plain: login.id
    else
      render plain: 'no'
    end
  end
  
  def craft
    craft = PerUserMasseuse.find(params[:tech_id])
    craft.job_class_status = params[:craft]
    craft.save
    render nothing:true
  end
  
  def language
    language = PerUserMasseuse.find(params[:tech_id])
    language.language = params[:language]
    language.save
    render nothing:true
  end  
end
