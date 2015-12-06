class Member < ActiveRecord::Base
	belongs_to :per_user,foreign_key: 'user_id'
	has_one :wechat_config,:dependent=>:delete
	has_one :wechat_user,:dependent=>:delete
	has_many :coupons_records,:dependent=>:delete_all
	belongs_to :per_user_qr_code,foreign_key: 'hand_code'
	has_many :qrcode_logs,:dependent=>:delete_all
	has_many :masseuses_reviews,:dependent=>:delete_all


	def get_type(member_id,log_id,status=1)
		type=1
		if id==member_id
			type=2
			if log_id != member.qrcode_logs.order(created_at: :desc).first.id
				status=2
			end
		elsif wechat_config.wechat_user.subscribe_time.nil?
			type=4
		else
			type=3
		end
		return type,status
	end
end
