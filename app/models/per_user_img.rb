class PerUserImg<ActiveRecord::Base
		belongs_to :per_user,foreign_key: "user_id"
	  mount_uploader :url,ImageAvatarUploader
		default_scope {where(del:1,status:1).order(:i_type)}
end
