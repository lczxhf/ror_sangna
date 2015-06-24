class MenuInfo < ActiveRecord::Base
	belongs_to :menu_info
	has_many   :menu_infos
	default_scope { order(:level,:order)}
end
