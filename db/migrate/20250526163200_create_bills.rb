class CreateBills < ActiveRecord::Migration[8.0]
  def change
    create_table :bills do |t|
      t.references :division, null: false, foreign_key: true
      t.date :date_issued
      t.date :billing_period_start
      t.date :billing_period_end

      t.timestamps
    end
  end
end
