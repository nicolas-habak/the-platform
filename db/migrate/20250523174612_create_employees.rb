class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :sex
      t.date :date_of_birth
      t.references :employer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
