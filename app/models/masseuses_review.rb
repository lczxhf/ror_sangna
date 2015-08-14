class MasseusesReview < ActiveRecord::Base
	belongs_to :order_by_masseuse,foreign_key: 'order_id'
	default_scope { where(del:1) }
	self.primary_key = 'id'
end
