class OrderByMasseuse<ActiveRecord::Base
			belongs_to :per_user,foreign_key: "user_id"
			belongs_to :member
			belongs_to :per_user_masseuse,foreign_key: "masseuse_id"
			belongs_to :per_user_project,foreign_key: "project_id"
end
