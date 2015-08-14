class MasseusesWorkShift < ActiveRecord::Base
		belongs_to :per_user,foreign_key: 'user_id'
		has_many :per_user_masseuses,foreign_key: "work_shift_id"
end
