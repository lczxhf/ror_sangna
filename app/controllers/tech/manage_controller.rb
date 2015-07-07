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
	end
end
