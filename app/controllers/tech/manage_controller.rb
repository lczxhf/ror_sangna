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
    appoint.appointment_number = (Time.now.to_i).to_s + rand(1...9999).to_s
    appoint.project_id = params[:pro]
    appoint.user_id = params[:tech_user_id]
    appoint.project_name = params[:pro_name]
    appoint.masseuses_job_number = params[:job_number]
    appoint.a_type = params[:a_type]
    appoint.member_tel = params[:tel]
    appoint.member_username = params[:client_name]
    appoint.status = 1
    appoint.service_time = params[:client_time]
    appoint.create_time = Time.now
    if appoint.save
      arr = []
      appoint = arr.push(appoint)
      render json: appoint
    else
      render plain: 'no'
    end
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

  def modifynumber
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
    user = PerUserMasseuse.where(username: tel,del: 1)
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
    user = PerUserMasseuse.where(username: tel,del: 1)
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

  end

  def modifysex
    changesex = PerUserMasseuse.find(params[:tech_id])
    changesex.sex = params[:ck_sex]
    if changesex.save
      render plain: "#{changesex.sex.to_s}"
    else
      render plain: "no"
    end
  end
#订单上钟
  def orderup
     orders = OrderByMasseuse.new
     orders.user_id = params[:tech_user_id]
     orders.masseuse_id = params[:tech_id]
     orders.project_id = params[:project_name_num]
     orders.status = params[:up]
     orders.start_time = Time.now
		 puts Time.now
     orders.room_number = params[:room_number]

     pull = PerUserQrCode.where(hand_code: params[:hand_num],user_id: params[:tech_user_id]).first
     if pull
       orders.hand_number = pull.id
       if orders.save
         status = PerUserMasseuse.find(params[:tech_id])
         if params[:next]== 'out'
          status.work_status = 1
         else
          status.work_status = 3
         end
          status.save
         render plain: "#{orders.id.to_s}"
       else
         render plain: 'no'
       end
     else
       render plain: 'no'
     end

  end
#订单下钟
  def orderdown
     handnum = OrderByMasseuse.find(params[:order_id])
     tech_status = PerUserMasseuse.find(params[:tech_id]);
     if params[:next]=='receiving'
      tech_status.work_status = 2
     else
      tech_status.work_status = 1
     end
     tech_status.save

     if handnum
       pull = PerUserQrCode.where(hand_code: params[:hand_num],user_id: params[:tech_user_id]).first
       if pull && pull.status==2
				 handnum.status=2
         handnum.end_time = Time.now
         #handnum.hand_number = params[:hand_num]


         member = Member.where(user_id: params[:tech_user_id],hand_code: pull.id).first
					
         if member
            handnum.member=member
            handnum.save
            uri = URI('http://weixin.linkke.cn/wechat/gzh_manage/sent_consumption_message')
            res = Net::HTTP.post_form(uri, 'h' => pull.hand_code, 'o_id' => handnum.id)
          end

         render plain: 'ok'
       else
         render plain: 'no'
       end


     end
  end

  def modifyident
    ident = PerUserMasseuse.find(params[:tech_id])
    ident.identification_numbers = params[:ident]
    if ident.save
      render plain: "#{ident.identification_numbers.to_s}"
    else
      render plain: 'no'
    end
  end

  def modifyentry
     enter = PerUserMasseuse.find(params[:tech_id])
     enter.entry_time = params[:work_time]
     if enter.save
       render plain: "#{enter.entry_time.to_s}"
     else
       render  plain: 'no'
     end
  end

  def modifycraft
    tech = PerUserMasseuse.find(params[:tech_id])
    tech.job_class_status = params[:craft]
    tech.projects_id = params[:pro]
    if tech.save
      render plain: ''
    else
      render nothing:true
    end
  end

  def modifylanguage
    language = PerUserMasseuse.find(params[:tech_id])
    language.language = params[:language]
    if language.save
      render plain: "#{language.language.to_s}"
    end
  end

  def modifyproject
    project = PerUserMasseuse.find(params[:tech_id])
    puts 111
    puts project.projects_id
    puts params[:project]
    puts 222
    project.projects_id = params[:project]
    if project.save
      render plain: "#{project.projects_id.to_s}"
    end
  end

  def changepwd
    changepwd = PerUserMasseuse.authenticate_id(params[:tech_id],params[:old_pwd])
    if changepwd
      pwd = params[:pwd]
      apwd = params[:apwd]
      if pwd == apwd
        changepwd.pwd = pwd
        changepwd.save
        render plain: "ok"
      else
        render plain: '密码不一致'
      end
    else
      render plain: '密码错误'
    end
  end

  def getaddress
    pro =  Region.where(regions_CODE: params[:pro]).first
    city =  Region.where(regions_CODE: params[:city]).first
    area =  Region.where(regions_CODE: params[:are]).first
    render plain: "#{pro.regions_NAME.to_s}#{city.regions_NAME.to_s}#{area.regions_NAME.to_s}"
  end

  def nativeplace
    pro =  Region.where(regions_CODE: params[:pro]).first
    city =  Region.where(regions_CODE: params[:city]).first
    render plain: "#{pro.regions_NAME.to_s}#{city.regions_NAME.to_s}"
  end

  def modifynativaplace
    native = PerUserMasseuse.find(params[:tech_id])
    native.native_province_id = params[:pro]
    native.native_city_id = params[:city]
    if native.save
      render plain: "#{native.native_province_id.to_s},#{native.native_city_id.to_s}"
    end
  end

  def modifyaddress
    address = PerUserMasseuse.find(params[:tech_id])
    address.province_id = params[:pro]
    address.city_id = params[:city]
    address.district_id = params[:are]
    address.address = params[:address]
    if address.save
      render plain: "#{address.province_id.to_s},#{address.city_id.to_s},#{address.district_id.to_s},#{address.address.to_s}"
    end
  end

  def jobstatus
    jobstatus = PerUserMasseuse.find(params[:tech_id])
    render plain: jobstatus.work_status
  end

  def modifystatus
    jobstatus = PerUserMasseuse.find(params[:tech_id])
    jobstatus.work_status = params[:status]
    if jobstatus.save
      render plain: jobstatus.work_status
    end
  end

  def work_time
    work = PerUserMasseuse.find(params[:tech_id])
    work.work_time_start = params[:work_start]
    work.work_time_end = params[:work_end]
    if work.save
      render plain: 'ok'
    else
      render plain: 'no'
    end
  end

  # 获取工种
  def get_craft
    id = params[:tech_user_id]
    pros = PerUserProject.where(user_id:params[:tech_user_id],p_type: 1,del: 1);
    render json: pros
  end

  # 获取该工种的项目
  def get_pro
    pros = PerUserProject.where(parent_id: params[:id])
    render json: pros
  end

  #获取技师所属工种
  def get_tech_craft
    craft = PerUserMasseuse.find(params[:tech_id])
    name = PerUserProject.select('id,name').where(id: craft.job_class_status,user_id: params[:tech_user_id])
    render json: name
  end

  #获取预约清单
  def subscribe
    appoints = Appointment.where(masseuses_job_number: params[:job_number],status: 1,user_id: params[:tech_user_id])
    render json: appoints
  end

  #删除预约
  def subscribe_de
    subde = Appointment.find(params[:id])
    subde.status = 2
    if subde.save
      render plain: 'ok'
    else
      render plain: 'no'
    end
  end

  #获取技师上班时间
  def get_atwork_time
    work = PerUserMasseuse.find(params[:tech_id])
    if work.work_time_start && work.work_time_end
      render plain: "#{work.work_time_start.strftime("%H:%M")},#{work.work_time_end.strftime("%H:%M")}"
    else
      render plain: 'no'
    end
  end

  #更改技师状态
  def get_atwork_status
    tech = PerUserMasseuse.find(params[:tech_id])
    status = params[:start_work]
    if status == 'start_work'
      tech.work_status = 2
      if tech.save
        render plain: 'start_work'
      end
    elsif  status == 'at_work'
      tech.work_status = 1
      if tech.save
        render plain: 'at_work'
      end
    end
  end

end
