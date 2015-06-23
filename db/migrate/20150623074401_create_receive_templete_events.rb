class CreateReceiveTempleteEvents < ActiveRecord::Migration
  def change
    create_table :receive_templete_events do |t|
				t.references :receive_message
				t.references :sent_templete
				t.string :status
				t.text :info
    end
  end
end
