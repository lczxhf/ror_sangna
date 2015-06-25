class ReceiveTempleteEvent < ActiveRecord::Base
	belongs_to :receive_message
	belongs_to :sent_templete
end
