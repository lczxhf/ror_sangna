class PerUserProject < ActiveRecord::Base
	has_many :order_by_masseuses,foreign_key: 'project_id'
	default_scope {where(del:1,status:1)}
end
