class CouponsRule < ActiveRecord::Base
		has_many :coupons_records,foreign_key: 'coupons_rules_id'
end
