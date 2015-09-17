class UserCouponsClass < ActiveRecord::Base
	belongs_to :coupons_class,foreign_key: 'coupons_classes_id'
	belongs_to :per_user,foreign_key: 'user_id'
end