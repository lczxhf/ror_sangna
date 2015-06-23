class CreateQrcodes < ActiveRecord::Migration
  def change
    create_table :qrcodes do |t|
			t.string :expire_second
			t.string :action_name
			t.string :scene
			t.string :url
			t.string :ticket
			t.text   :info
			t.references :sangna_config
      t.timestamps     
		end
  end
end
