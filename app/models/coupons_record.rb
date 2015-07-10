class CouponsRecord < ActiveRecord::Base
	belongs_to :coupons_rule,foreign_key: 'coupons_rules_id'
	belongs_to :order_by_masseuse,foreign_key: 'order_id'
	belongs_to :member
end
