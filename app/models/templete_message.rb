class TempleteMessage < ActiveRecord::Base
	belongs_to :templete_number
	belongs_to :sangna_config
	has_many :sent_templetes
end
