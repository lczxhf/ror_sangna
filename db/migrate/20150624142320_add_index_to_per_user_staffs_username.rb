class AddIndexToPerUserStaffsUsername < ActiveRecord::Migration
  def change
		add_index :per_user_staffs, :username, unique: true
  end
end
