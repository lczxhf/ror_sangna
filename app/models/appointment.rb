class Appointment < ActiveRecord::Base
	belongs_to :per_user_project,foreign_key: 'project_id'
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :per_user_masseuse,foreign_key: 'masseuses_id'
	self.primary_key = :id
end
