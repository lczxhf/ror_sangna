class CreateTemplteMessages < ActiveRecord::Migration
  def change
    create_table :templte_messages do |t|
			t.references :sangna_config
			t.references :tomplete_number
			t.string :tmplete_id
      t.timestamps 
    end
  end
end
