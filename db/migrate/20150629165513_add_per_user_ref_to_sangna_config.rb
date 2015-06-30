class AddPerUserRefToSangnaConfig < ActiveRecord::Migration
  def change
    add_reference :sangna_configs, :per_user, index: true
  end
end
