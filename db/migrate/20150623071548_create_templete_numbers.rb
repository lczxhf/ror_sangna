class CreateTempleteNumbers < ActiveRecord::Migration
  def change
    create_table :templete_numbers do |t|
			t.string :number
			t.string :industry
			t.string :topic
			t.string :fields
			t.string :name
      t.timestamps 
    end
  end
end
