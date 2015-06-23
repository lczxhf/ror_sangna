class CreateSentTempletes < ActiveRecord::Migration
  def change
    create_table :sent_templetes do |t|
			t.references :templete_message
			t.references :sangna_config
			t.references :wechat_config
			t.text   :date
			t.string :url
			t.string :msgid
			t.string :state
      t.timestamps 
    end
  end
end
