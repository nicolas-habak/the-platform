class CreateDivisions < ActiveRecord::Migration[8.0]
  def change
    create_table :divisions do |t|
      t.string :name
      t.string :code
      t.references :employer, null: false, foreign_key: true
      t.references :policy, null: false, foreign_key: true

      t.timestamps
    end
  end
end
