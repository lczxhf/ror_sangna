class ReceiveMessage < ActiveRecord::Base
	belongs_to :sangna_config
	belongs_to :wechat_config
end
