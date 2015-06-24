class AddPasswordDigestToPerUserStaffs < ActiveRecord::Migration
  def change
    add_column :per_user_staffs, :password_digest, :string
  end
end
