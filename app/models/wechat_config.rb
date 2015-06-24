class WechatConfig < ActiveRecord::Base
	belongs_to :sangna_config
	has_one :wechat_user

end
