class CreateRedbages < ActiveRecord::Migration
  def change
    create_table :redbages do |t|
			t.string :nickname
			t.string :sendname
			t.integer :total_amount
			t.integer :min_value
			t.integer :max_value
			t.integer :total_num
			t.string  :wishing
			t.string  :action_name
			t.string  :remark
			t.string  :mch_billno
			t.string :logo_url
			t.string :share_content
			t.string :share_url
			t.string :share_imgurl
			t.string :send_listid
			t.string :sent_time
			t.references :wechat_config
      t.timestamps 
		end
  end
end
