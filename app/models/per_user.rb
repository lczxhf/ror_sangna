class PerUser < ActiveRecord::Base
	has_one :sangna_config
	has_many :masseuses_collects
end
