class CreateDists < ActiveRecord::Migration
  def change
    create_table :dists do |t|
      t.string :state
      t.string :name
      t.references :build, index: true

      t.timestamps
    end
  end
end
