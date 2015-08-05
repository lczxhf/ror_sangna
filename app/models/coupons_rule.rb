class CouponsRule < ActiveRecord::Base
		has_many :coupons_records,foreign_key: 'coupons_rules_id',dependent: :delete_all
		belongs_to :per_user,foreign_key: 'user_id'
end
