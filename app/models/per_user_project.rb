class PerUserProject < ActiveRecord::Base
	has_many :order_by_masseuses,foreign_key: 'project_id'
	belongs_to :per_user,foreign_key: "user_id"
	belongs_to :per_user_project,foreign_key: 'parent_id'
	has_many   :per_user_projects,foreign_key: "parent_id"	
	scope :open, ->{where(del:1,status:1)}
end
