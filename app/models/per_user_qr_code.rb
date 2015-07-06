class PerUserQrCode<ActiveRecord::Base
		belongs_to :per_user,foreign_key: "user_id"
		default_scope {where(del:1)}
end
