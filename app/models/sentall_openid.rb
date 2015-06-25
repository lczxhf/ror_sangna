class SentallOpenid < ActiveRecord::Base
	belongs_to :sentall_data
	belongs_to :wechat_config
	belongs_to :sangna_config
end
