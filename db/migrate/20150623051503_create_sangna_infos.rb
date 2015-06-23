class CreateSangnaInfos < ActiveRecord::Migration
  def change
    create_table :sangna_infos do |t|
			t.string :nickname
			t.string :headimgurl
			t.string :service_type
			t.string :verify_type
			t.string :alias
			t.string :user_name
			t.string :qrcode_url
			t.string :location_report
			t.string :voice_recognize
			t.string :customer_service
			t.references :per_user
			t.references :sangna_config
      t.timestamps 
    end
  end
end
