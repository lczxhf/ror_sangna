class Member < ActiveRecord::Base
	belongs_to :per_user,foreign_key: 'user_id'
	has_one :wechat_config
	has_one :wechat_user
	has_many :coupons_records
	belongs_to :per_user_qr_code,foreign_key: 'hand_code'
	has_many :qrcode_logs
end
