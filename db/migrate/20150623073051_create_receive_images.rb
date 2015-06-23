class CreateReceiveImages < ActiveRecord::Migration
  def change
    create_table :receive_images do |t|
				t.references :receive_message
				t.string :picurl
				t.string :media_id
    end
  end
end
