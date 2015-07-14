class WechatConfig < ActiveRecord::Base
	belongs_to :member
	belongs_to :sangna_config
	has_one :wechat_user
	self.primary_key = :id
end
