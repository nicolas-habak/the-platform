class CreateBillingEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :billing_entries do |t|
      t.references :bill, null: false, foreign_key: true
      t.references :insurance_profile, null: false, foreign_key: true
      t.string :life_benefit
      t.decimal :life
      t.string :health_benefit
      t.decimal :health
      t.string :dental_benefit
      t.decimal :dental
      t.boolean :smoker_benefit
      t.decimal :smoker

      t.timestamps
    end
  end
end
