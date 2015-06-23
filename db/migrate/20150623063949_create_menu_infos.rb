class CreateMenuInfos < ActiveRecord::Migration
  def change
    create_table :menu_infos do |t|
			t.references :menu_info
			t.string :name
			t.string :type
			t.string :level
			t.string :order
			t.string :content
      t.timestamps 
    end
  end
end
