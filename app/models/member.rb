class Member < ActiveRecord::Base
	has_one :wechat_config
	has_one :wechat_user
	has_many :coupons_records
end
