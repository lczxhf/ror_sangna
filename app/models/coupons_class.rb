class CouponsClass < ActiveRecord::Base
	has_many :user_coupons_classes,foreign_key: 'coupons_classes_id'
	has_many :ab_rules,class_name: 'UserAbProjectsCouponsRule',foreign_key: 'coupons_classes_id'
	has_many :coupons_rules,foreign_key: 'coupons_classes_id'
	has_many :coupons_records,foreign_key: 'coupons_classes_id'
end