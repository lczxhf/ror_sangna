class PerUserProject < ActiveRecord::Base
	default_scope {where(del:1,status:1)}
end
