class CreateInsuranceProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_profiles do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :division, null: false, foreign_key: true
      t.boolean :life
      t.string :health
      t.string :dental
      t.boolean :smoker
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
