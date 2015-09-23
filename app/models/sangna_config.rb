class SangnaConfig < ActiveRecord::Base
	belongs_to :per_user
	has_one :sangna_info
	has_many :wechat_configs
	has_many :groups
	has_many :templete_messages
	self.primary_key = :id
	mount_uploader :qr_code,QrcodeUploader
	mount_uploader :original_qr_code,QrcodeUploader
	before_save :check_token

	def check_token
			if token.blank?
					false
			else
					true
			end
	end
end
