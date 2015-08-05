class Member < ActiveRecord::Base
	belongs_to :per_user,foreign_key: 'user_id'
	has_one :wechat_config
	has_one :wechat_user
	has_many :coupons_records
end
