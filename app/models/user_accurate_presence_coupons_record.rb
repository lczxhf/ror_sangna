class UserAccuratePresenceCouponsRecord < ActiveRecord::Base
	has_many :coupons_records,foreign_key: "accurate_presence_coupons_record_id"
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :accurate_record,class_name: 'UserAccuratePresenceCouponsRecord',foreign_key: 'accurate_presence_coupons_id'
end