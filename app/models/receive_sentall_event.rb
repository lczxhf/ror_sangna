class ReceiveSentallEvent < ActiveRecord::Base
	belongs_to :receive_message
	belongs_to :sentall_data
end
