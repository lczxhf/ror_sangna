class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
			t.string :wcgroup_id
			t.string :name
			t.references :sangna_config
      t.timestamps 
    end
  end
end
