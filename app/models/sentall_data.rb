class SentallData < ActiveRecord::Base
	belongs_to :sangna_config
	has_one :sentall_group
	has_one :sentall_openid
	has_one :receive_sentall_event
end
