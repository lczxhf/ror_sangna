class MasseusesCollect < ActiveRecord::Base
		belongs_to :per_user
		belongs_to :member
		belongs_to :per_user_masseuse
end
