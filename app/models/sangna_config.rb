class SangnaConfig < ActiveRecord::Base
	has_one :sangna_info
	has_many :wechat_configs
	has_many :groups
	has_many :templete_messages
end
