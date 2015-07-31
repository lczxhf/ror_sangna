class CouponsRecord < ActiveRecord::Base
	belongs_to :coupons_rule,foreign_key: 'coupons_rules_id'
	belongs_to :order_by_masseuse,foreign_key: 'from_order_id'
	belongs_to :member
	belongs_to :per_user,foreign_key: 'user_id'
end
