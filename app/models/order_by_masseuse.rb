class OrderByMasseuse<ActiveRecord::Base
			belongs_to :per_user,foreign_key: "user_id"
			belongs_to :member
			belongs_to :per_user_masseuse,foreign_key: "masseuse_id"
			belongs_to :per_user_project,foreign_key: "project_id"
			belongs_to :per_user_qr_code,foreign_key: 'hand_number'
			has_many :coupons_records,foreign_key: 'from_order_id'
			has_one  :masseuses_review,foreign_key: 'order_id'
			has_many :technician_level_remarks,foreign_key: 'order_id'
			self.primary_key = :id
end
