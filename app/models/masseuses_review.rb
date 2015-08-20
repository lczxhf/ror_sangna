class MasseusesReview < ActiveRecord::Base
	belongs_to :order_by_masseuse,foreign_key: 'order_id'
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :per_user_masseuse,foreign_key: 'masseuses_id'
	belongs_to :member,foreign_key: 'member_id'
	belongs_to :technique_evalution
	default_scope { where(del:1) }
	self.primary_key = 'id'
end
