class CreateSentallOpenids < ActiveRecord::Migration
  def change
    create_table :sentall_openids do |t|
			t.references :sangna_config
			t.references :sentall_data
			t.references :wechat_config
      t.timestamps 
    end
  end
end
