class ProjectRelation < ActiveRecord::Base
	 belongs_to :per_user,foreign_key: 'user_id'
   belongs_to :per_user_project,foreign_key: 'project_id'
	 belongs_to :per_user_type,class_name: 'PerUserProject',foreign_key: 'type_id'
	 self.primary_key='project_id'
end
