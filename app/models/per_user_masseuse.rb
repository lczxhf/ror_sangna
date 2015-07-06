class PerUserMasseuse < ActiveRecord::Base
	 default_scope {where(del:1)}
	 mount_uploader :img,ImageAvatarUploader

	require 'bcrypt'
	attr_accessor :pwd,:pwdagain
	#回调
	  before_save :encrypt_password, :if => [:password_required, :confirm_again]
	
	#  #验证手机、密码是否正确的方法
	    def self.authenticate_mobile(mobile, pwd)
	        account = where(:username=> mobile).first 
          account && account.has_password?(pwd)  ? account : nil
	     end
	
	    #验证密码是否正确的方法
	    def has_password?(pwd)
          puts password
	        ::BCrypt::Password.new(password) == pwd
	    end
	    private
	    #加密密码
	    def encrypt_password
	       self.password = ::BCrypt::Password.create(self.pwd)
		  end

	    def password_required
	        password.blank? || self.pwd.present?
	    end  

			def confirm_again
						pwd==pwdagain ? true : false
			end

end
