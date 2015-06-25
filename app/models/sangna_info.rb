class SangnaInfo < ActiveRecord::Base
	belongs_to :per_user
	belongs_to :sangna_config
end
