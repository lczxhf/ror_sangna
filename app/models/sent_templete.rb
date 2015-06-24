class SentTemplete < ActiveRecord::Base
	belongs_to :templete_message
	belongs_to :wechat_config
	belongs_to :sangna_config
	has_one :receive_templete_event
end
