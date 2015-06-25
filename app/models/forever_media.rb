class ForeverMedia < ActiveRecord::Base
	belongs_to :sangna_config
	has_many   :articles
end
