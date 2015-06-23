class CreateWechatUsers < ActiveRecord::Migration
  def change
    create_table :wechat_users do |t|
			t.string :nickname
			t.boolean :sex
			t.string :city
			t.string :country
			t.string :province
			t.string :language
			t.string :headimgurl
			t.string :subscribe_time
			t.string :remark
			t.string :unionid
			t.references :group
			t.references :member
      t.timestamps 
    end
  end
end
