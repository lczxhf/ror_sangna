class CreateReceiveLinks < ActiveRecord::Migration
  def change
    create_table :receive_links do |t|
				t.references :rereive_message		
				t.string :title
				t.text   :description
				t.string :url
    end
  end
end
