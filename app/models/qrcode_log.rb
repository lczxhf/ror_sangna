class QrcodeLog < ActiveRecord::Base
		belongs_to :per_user_qr_code
		belongs_to :member
		has_many :coupons_records
		has_many :order_by_masseuses
		belongs_to :per_user,foreign_key: 'user_id'
end
