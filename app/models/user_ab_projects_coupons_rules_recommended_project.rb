class UserAbProjectsCouponsRulesRecommendedProject < ActiveRecord::Base
	has_many :coupons_records,foreign_key: 'projects_id'
	belongs_to :ab_rule,class_name: 'UserAbProjectsCouponsRule',foreign_key: 'user_ab_projects_coupons_rules_id'
	belongs_to :per_user,foreign_key:'user_id'
	belongs_to :per_user_project,foreign_key: 'projects_id'
end