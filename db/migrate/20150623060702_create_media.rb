class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
			t.string :mtype
			t.string :url
			t.string :media_id
			t.references :sangna_config
      t.timestamps 
    end
  end
end
