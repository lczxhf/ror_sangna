class Tech::ManageController < ApplicationController
  def project
    job = PerUserMasseuse.find(params[:tech_id])
    job.user_id
    project = job.projects_id.split(',')
    work_list = []
    project.each do |p|
      club = PerUserProject.where("id = ? AND user_id = ?",p,job.user_id).first;
      job_list = {}
      job_list['id']= club.id
      job_list['name'] = club.name
      job_list['time'] = club.duration
      work_list.push(job_list)
    end
    render json: work_list
  end

  def job_number
    job = PerUserMasseuse.find(params[:tech_id])
    render plain: job.job_number
  end

  def appointment
    appoint = Appointment.new
  end

  def gettime
    protime = PerUserProject.select('duration').where('id = ? And user_id = ?',params[:tech_id],params[:tech_user_id]).first
    render plain: protime.duration.to_s
  end

  def details
    details = PerUserMasseuse.find(params[:tech_id])
    render json: details
  end

  def modifyname
    tech =	PerUserMasseuse.find(params[:tech_id])
    tech.name = params[:name]
    if tech.save
      render plain: 'ok'
    else
      render nothing:true
    end
  end

  def modifycraft
    tech = PerUserMasseuse.find(params[:tech_id])
    tech.job_number = params[:job_number]
    if tech.save
      render plain: 'ok'
    else
      render noting:true
    end

  end

  def findpwd
    verify = rand(1000..9999).to_s   
    puts verify
    tel =  params[:user]
    puts tel
    user = PerUserMasseuse.where(username: tel).first   
    if user
      Rails.cache.write(tel,verify)
      uri = URI("http://106.ihuyi.cn/webservice/sms.php?method=Submit")
      Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|             request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
      request.set_form_data({"account"=>"cf_zxy0506","password"=>"zxy0506","mobile"=>"#{tel}","content"=>"您的验证码是：#{verify}。请不要把验证码泄露给其他人。如非本人操作，可不用理会！"})
    response=http.request request
      puts  response.body
      end
    else
      render plain: '请输入有效的用户名'
    end
  end

  def modifypwd
    tel = params[:user]
    tel_code = Rails.cache.read(tel)
    changepwd = PerUserMasseuse.new
    changepwd.username = tel
    verify = params[:code]
    user = PerUserMasseuse.where(username: tel).first
    if user  &&  verify == tel_code
      render plain: "#{user.id}"
    else
      render plain: 'no'
    end
  end

  def ensurepwd
       changepwd = PerUserMasseuse.find(params[:tech_id])
       pwd = params[:pwd]
       apwd = params[:apwd]
       if pwd == apwd
          changepwd.pwd = pwd
          changepwd.save
          render plain: "#{changepwd.id},#{changepwd.user_id}"
       else
          render plain: '密码不一致'
       end
       changepwd.pwd = params[:pwd]
       
  end
end
