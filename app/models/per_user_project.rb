class PerUserProject < ActiveRecord::Base
	has_many :order_by_masseuses,foreign_key: 'project_id'
	belongs_to :per_user,foreign_key: "user_id"
#	belongs_to :per_user_project,foreign_key: 'parent_id'
#	has_many   :per_user_projects,foreign_key: "parent_id"	
	has_many :project_relations,foreign_key: 'project_id'
	has_many :type_relations,->{where(del:1)},class_name: 'ProjectRelation',foreign_key: 'type_id'
	scope :open, ->{where(del:1,status:1)}

	def get_format_time(minutes)
			hour=minutes/60
			minute=minutes-hour*60
			if minute==0
					"#{hour}小时"
			else
					"#{hour}小时#{minute}分钟"
			end
	end
end
