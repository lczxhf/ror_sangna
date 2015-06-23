class CreateSangnaConfigs < ActiveRecord::Migration
  def change
    create_table :sangna_configs do |t|
			t.string :code
			t.string :token
			t.string :refresh_token
			t.string :appid
			t.string :func_info
      t.timestamps 
    end
  end
end
