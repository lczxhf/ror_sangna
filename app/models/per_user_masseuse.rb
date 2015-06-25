class PerUserMasseuse < ActiveRecord::Base
<<<<<<< HEAD
	 mount_uploader :img,ImageAvatarUploader
=======
	require 'bcrypt'
	attr_accessor :pwd
	#回调
	  before_save :encrypt_password, :if => :password_required
	
	#  #验证手机、密码是否正确的方法
	    def self.authenticate_mobile(mobile, pwd)
	        account = where(:username=> mobile).first 
          account && account.has_password?(pwd)  ? account : nil
	     end
	
	    #验证密码是否正确的方法
	    def has_password?(pwd)
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
>>>>>>> 4cae071ed23f78c05057e33daea81b794431aa91
end
