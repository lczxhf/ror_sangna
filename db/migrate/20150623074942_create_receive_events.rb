class CreateReceiveEvents < ActiveRecord::Migration
  def change
    create_table :receive_events do |t|
				t.references :receive_message
				t.string :event
				t.string :event_key
				t.string :ticket
    end
  end
end
