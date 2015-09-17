class UserAbProjectsCouponsRule < ActiveRecord::Base
	has_many :ab_recommended_projects,class_name: 'UserAbProjectsCouponsRulesRecommendedProject'
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :per_user_project,foreign_key: 'original_project_id'
	belongs_to :coupons_class,foreign_key: 'coupons_classes_id'
end