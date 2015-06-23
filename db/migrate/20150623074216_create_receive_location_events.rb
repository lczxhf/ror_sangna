class CreateReceiveLocationEvents < ActiveRecord::Migration
  def change
    create_table :receive_location_events do |t|
				t.references :receive_message
				t.float :latitude
				t.float :longitude
				t.float :precision
    end
  end
end
