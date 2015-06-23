class CreateSentallData < ActiveRecord::Migration
  def change
    create_table :sentall_data do |t|
			t.references :sangna_config
			t.string :type
			t.string :data
			t.string :info
			t.string :media_id
			t.string :state
      t.timestamps 
    end
  end
end
