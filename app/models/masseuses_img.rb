class MasseusesImg<ActiveRecord::Base
		belongs_to :per_user_masseuse,foreign_key: "masseuses_id"
		belongs_to :per_user,foreign_key: "user_id"
		scope :active,->{where(del:1,status:1).order(:i_type)}
	  mount_uploader :url,TechAvatarUploader
end
