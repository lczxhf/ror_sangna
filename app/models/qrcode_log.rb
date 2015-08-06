class QrcodeLog < ActiveRecord::Base
		belongs_to :per_user_qr_code
		belongs_to :member
		has_one :coupons_record
end
