class UserQrCodeRule < ActiveRecord::Base
		belongs_to :per_user,foreign_key: 'user_id'
		has_many :per_user_qr_codes,foreign_key: 'rule_id'
end
