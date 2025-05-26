class CreateDependants < ActiveRecord::Migration[8.0]
  def change
    create_table :dependants do |t|
      t.references :insurance_profile
      t.string :name
      t.date :date_of_birth
      t.string :relation
      t.boolean :has_disability

      t.timestamps
    end
  end
end
