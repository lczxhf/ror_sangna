class PerUserMasseuse < ActiveRecord::Base
	has_many :masseuses_imgs,foreign_key: "masseuses_id"
	has_many :order_by_masseuses,foreign_key: 'masseuse_id',dependent: :delete_all
	has_many :per_user_masseuses,foreign_key: 'job_class_status'
	belongs_to :per_user,foreign_key: "user_id"	
	belongs_to :per_user_project,foreign_key: 'job_class_status'
	 mount_uploader :img,TechAvatarUploader

	require 'bcrypt'
	attr_accessor:pwd
	#回调
	  before_save :encrypt_password, :if => [:password_required]
    
	
	#  #验证手机、密码是否正确的方法
	    def self.authenticate_mobile(mobile, pwd)
	        account = where(:username=> mobile).first 
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
