class PerUserInfo < ActiveRecord::Base
		belongs_to :per_user,foreign_key: "user_id"
		self.primary_key = :id
end
