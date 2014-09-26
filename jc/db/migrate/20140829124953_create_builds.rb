class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.integer :key_id
      t.timestamps
    end
  end
end
