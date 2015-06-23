class CreateWechatConfigs < ActiveRecord::Migration
  def change
    create_table :wechat_configs do |t|
			t.string :code
			t.string :token
			t.string :refresh_token
			t.string :openid
			t.string :scope
			t.references :sangna_config
      t.timestamps 
    end
  end
end
