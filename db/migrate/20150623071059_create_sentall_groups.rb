class CreateSentallGroups < ActiveRecord::Migration
  def change
    create_table :sentall_groups do |t|
			t.references :group
			t.references :sangna_config
			t.references :sentall_data
			t.boolean :is_to_all
      t.timestamps 
    end
  end
end
