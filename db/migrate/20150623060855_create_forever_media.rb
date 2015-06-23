class CreateForeverMedia < ActiveRecord::Migration
  def change
    create_table :forever_media do |t|
			t.string :mtype
			t.string :url
			t.string :media_id
			t.string :info
			t.references :sangna_config
      t.timestamps 
    end
  end
end
