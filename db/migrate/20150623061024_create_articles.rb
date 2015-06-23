class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
			t.references :sangna_config
			t.references :forever_meida
			t.string :title
			t.string :author
			t.string :digest
			t.boolean :show_cover_pic
			t.string :content
			t.string :content_source_url
			t.string :media_id
      t.timestamps 
    end
  end
end
