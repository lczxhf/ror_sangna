class CreateReveiveVoices < ActiveRecord::Migration
  def change
    create_table :reveive_voices do |t|
				t.references :receive_message		
				t.string :media_id
				t.string :format
    end
  end
end
