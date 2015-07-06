class MasseusesImg<ActiveRecord::Base
		belongs_to :per_user_masseuse,foreign_key: "masseuses_id"
		belongs_to :per_user,foreign_key: "user_id"
		default_scope {where(del:1,status:2).order(:i_type)}
	  mount_uploader :url,ImageAvatarUploader
end
