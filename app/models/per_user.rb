class PerUser < ActiveRecord::Base
	has_one :sangna_config
	has_one :per_user_info,foreign_key: "user_id"
	has_many :masseuses_collects
	has_many :per_user_imgs,foreign_key: "user_id"
	has_many :masseuses_imgs,foreign_key: "user_id"
	has_many :per_user_masseuses,foreign_key: "user_id"
	has_many :per_user_qr_codes,foreign_key: "user_id"
	has_many :order_by_masseuses,foreign_key: 'user_id'
	has_many :coupons_rules,foreign_key: 'user_id'
	has_many :coupons_records,foreign_key: 'user_id'
	has_many :user_qr_code_rule,foreign_key: 'user_id'
	has_many :per_user_projects,foreign_key: "user_id"
	has_many :member,foreign_key: 'user_id'
end
