class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :employer, null: false, foreign_key: true
      t.string :number, null: false
      t.float :life, default: nil
      t.float :health_single, default: nil
      t.float :health_family, default: nil
      t.float :dental_single, default: nil
      t.float :dental_family, default: nil
      t.date :start_date, default: nil
      t.date :end_date, default: nil

      t.timestamps
    end
  end
end
