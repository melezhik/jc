class AddKeyToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :key, :integer, :unique => true
  end
end
