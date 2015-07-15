class WechatUser < ActiveRecord::Base
	belongs_to :wechat_config
	belongs_to :group
	belongs_to :member
	self.primary_key = :id
end
