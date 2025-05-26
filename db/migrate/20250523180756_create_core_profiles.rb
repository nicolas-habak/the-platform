class CreateCoreProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :core_profiles do |t|
      t.references :employee
      t.string :address
      t.float :salary
      t.integer :hours_per_week
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
