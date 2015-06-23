class CreateReceiveSentallEvents < ActiveRecord::Migration
  def change
    create_table :receive_sentall_events do |t|
				t.references :receive_message
				t.references :sentall_data
				t.integer :total_count
				t.integer :filter_count
				t.integer :sent_count
				t.integer :error_count
				t.string  :state
    end
  end
end
