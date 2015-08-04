class MasseusesReview < ActiveRecord::Base
	default_scope { where(del:1) }
	self.primary_key = 'id'
end
