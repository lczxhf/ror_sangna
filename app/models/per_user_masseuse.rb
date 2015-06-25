class PerUserMasseuse < ActiveRecord::Base
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
end
