class SentallGroup < ActiveRecord::Base
	belongs_to :sentall_data
	belongs_to :group
	belongs_to :sangna_config
end
