class TemplteMessage < ActiveRecord::Base
	belongs_to :tomplete_number
	belongs_to :sangna_config
	has_many :sent_templetes
end
