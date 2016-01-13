class UserMasseuseCouponsRule< ActiveRecord::Base
	belongs_to :per_user, foreign_key: 'user_id'
end
