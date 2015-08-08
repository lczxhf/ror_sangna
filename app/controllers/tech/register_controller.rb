class Tech::RegisterController < ApplicationController
  def register
    tel =  params[:user]
    tel_code = Rails.cache.read(tel)
    register = PerUserMasseuse.new
    register.username = tel
    register.pwd = params[:pwd]
    register.status = 2
    club = PerUser.find_by(poll_code: params[:club_code])

    verify = params[:verify]
    user = PerUserMasseuse.where(username: tel,del: 1)
    if club
      register.user_id = club.id
      if !user.empty?
        render plain: '用户名已经存在'
      else
        if verify != tel_code
          render plain: '验证码错误'
        else
          register.save
          registers = PerUserMasseuse.select('id','user_id').where(username: tel,del: 1)
          render json: registers
        end
      end
    else
      render plain: '注册码输入错误'
    end

  end

  def verify
    verify = rand(1000..9999).to_s
    tel =  params[:user]
    user = PerUserMasseuse.where(username: tel,del: 1)
    if !user.empty?
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
  end


  def upload
    upload = PerUserMasseuse.find(params[:tech_id])
    upload.entry_time = params[:entry]
    upload.name = params[:name]
    upload.sex = params[:sex]
    upload.language = params[:language]
    # upload.client_id = params[:cid]
    upload.job_class_status = params[:craft]
    upload.projects_id = params[:ck_string]
    upload.job_number = params[:job_number]
    upload.status = 1
    job_number = PerUserMasseuse.where(job_number: params[:job_number],user_id: params[:tech_user_id]).first
    if job_number
      render plain: '此工号已被占用'
    else
       if upload.save
          rs = "#{upload.id.to_s},#{upload.user_id.to_s}"
          render plain: rs
        else
          render nothing:true
        end
    end

  end


  def login
    user = params[:user]
    pwd = params[:pwd]
    login = PerUserMasseuse.authenticate_mobile(user, pwd)
    if login
      club = "#{login.id.to_s},#{login.user_id.to_s}"
      render plain: club
    else
      render plain: 'no'
    end
  end


end
