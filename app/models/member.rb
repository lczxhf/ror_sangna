class Member < ActiveRecord::Base
	belongs_to :per_user,foreign_key: 'user_id'
	has_one :wechat_config,:dependent=>:delete
	has_one :wechat_user,:dependent=>:delete
	has_many :coupons_records,:dependent=>:delete_all
	belongs_to :per_user_qr_code,foreign_key: 'hand_code'
	has_many :qrcode_logs,:dependent=>:delete_all
	has_many :masseuses_reviews,:dependent=>:delete_all
end
