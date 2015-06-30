class CreateMasseusesCollects < ActiveRecord::Migration
  def change
    create_table :masseuses_collects do |t|
			t.references :per_user
			t.references :per_user_masseuse
			t.references :member
			t.integer    :del
      t.timestamps
    end
  end
end
