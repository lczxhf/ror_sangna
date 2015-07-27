class WechatConfig < ActiveRecord::Base
	belongs_to :member,:dependent=>:delete
	belongs_to :sangna_config
	has_one :wechat_user,:dependent=>:delete
	self.primary_key = :id
end
