class CreateReceiveMessages < ActiveRecord::Migration
  def change
    create_table :receive_messages do |t|
			t.references :wechat_config
			t.references :sangna_config
			t.string     :msg_type
			t.string     :msgid
      t.timestamps
    end
  end
end
