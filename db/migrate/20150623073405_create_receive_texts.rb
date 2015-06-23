class CreateReceiveTexts < ActiveRecord::Migration
  def change
    create_table :receive_texts do |t|
				t.references :receive_message
				t.text :content
    end
  end
end
