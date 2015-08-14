class TechnicianLevelRemark < ActiveRecord::Base
	belongs_to :per_user_masseuse
	belongs_to :technician_level
	belongs_to :order_by_masseuse,foreign_key: 'order_id'
	belongs_to :member
end
