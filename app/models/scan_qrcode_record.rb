class ScanQrcodeRecord < ActiveRecord::Base
	belongs_to :per_user,foreign_key: 'user_id'
	belongs_to :member
	
end