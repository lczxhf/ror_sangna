class CouponOrder < ActiveRecord::Base
	belongs_to :coupons_project
	belongs_to :coupons_rule
	belongs_to :sangna_config
	belongs_to :wechat_config
end
