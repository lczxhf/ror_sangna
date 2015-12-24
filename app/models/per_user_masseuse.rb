class PerUserMasseuse < ActiveRecord::Base
	has_many :masseuses_imgs,foreign_key: "masseuses_id"
	has_many :order_by_masseuses,foreign_key: 'masseuse_id',dependent: :delete_all
	#has_many :per_user_masseuses,foreign_key: 'job_class_status'
	has_many :appointments,foreign_key: 'masseuses_id',dependent: :delete_all
	has_many :masseuses_reviews,foreign_key: 'masseuses_id',dependent: :delete_all
	has_many :masseuses_collects,dependent: :delete_all
	belongs_to :per_user,foreign_key: "user_id"	
	belongs_to :per_user_project,-> {where(del:1,status:1)},foreign_key: 'job_class_status'
	belongs_to :masseuses_work_shift,foreign_key: "work_shift_id"
	has_many :technician_level_remarks
	 mount_uploader :img,TechAvatarUploader
	scope :active,->{where(del:1,status:1)}
	require 'bcrypt'
	attr_accessor:pwd
	#回调
	  before_save :encrypt_password, :if => [:password_required]
    
	
	#  #验证手机、密码是否正确的方法
	    def self.authenticate_mobile(mobile, pwd)
	        account = where(:username=> mobile,del:1,status:1).first 
         	account && account.has_password?(pwd)  ? account : nil
	    end

	    def self.authenticate_id(id, pwd)
	        account = find(id)
         	account && account.has_password?(pwd)  ? account : nil
	    end
	
	    #验证密码是否正确的方法
	    def has_password?(pwd)
	        ::BCrypt::Password.new(password) == pwd
	    end


			def get_image(member_id,type=false)
						host="http://img.sudayi.com"
						case img_permission
						when 1 then
							 url=host+(masseuses_imgs.active.first.try(:url).try(:thumb).try(:url) || '') || "/images/default_img.png"
						when 2 then
							 url="/images/buttom_img.png"
						when 3 then
							 url=Member.where("hand_code != ''").where(id:member_id).first	? (host+(masseuses_imgs.active.first.try(:url).try(:thumb).try(:url) || '') || '/images/default_img.png')  : "/images/buttom_img.png"
						when 4 then
							url=OrderByMasseuse.where(masseuse_id:id,member_id:member_id).first ? (host+(masseuses_imgs.active.first.try(:url).try(:thumb).try(:url) || '') || '/images/default_img.png')  : "/images/buttom_img.png"
						end
						if type
						   url.gsub!("thumb_","")
						end
						if url.size==21
								url="/images/default_img.png"
						end
						puts url
						url
			end
	    private
	    #加密密码
	    def encrypt_password
				if self.pwd.present?
	       self.password = ::BCrypt::Password.create(self.pwd)
				end
		  end

	    def password_required
					if self.pwd.blank?
						 if password_changed?
									self.password=password_was
									true
						 else
								false	
						 end
					else
						 true	
					end
	    end  
end
