class CreateEmployers < ActiveRecord::Migration[8.0]
  def change
    create_table :employers do |t|
      t.string :name
      t.string :address, null: true

      t.timestamps
    end
  end
end
