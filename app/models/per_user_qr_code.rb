class PerUserQrCode<ActiveRecord::Base
		belongs_to :per_user,foreign_key: "user_id"
		belongs_to :user_qr_code_rule,foreign_key: 'rule_id'
		# default_scope {where(del:1)}
end
