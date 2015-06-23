class CreateReceiveVideos < ActiveRecord::Migration
  def change
    create_table :receive_videos do |t|
				t.references :reveive_message
				t.string :media_id
				t.string :thumb_media_id
    end
  end
end
