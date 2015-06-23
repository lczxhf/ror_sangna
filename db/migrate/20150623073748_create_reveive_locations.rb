class CreateReveiveLocations < ActiveRecord::Migration
  def change
    create_table :reveive_locations do |t|
				t.references :receive_message
				t.float :location_x
				t.float :location_y
				t.float :scale
				t.string :lable
    end
  end
end
