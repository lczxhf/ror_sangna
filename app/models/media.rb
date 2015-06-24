class Media < ActiveRecord::Base
	belongs_to :sangna_config
	mount_uploader :url,ImageAvatarUploader
end
