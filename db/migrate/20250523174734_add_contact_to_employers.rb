class AddContactToEmployers < ActiveRecord::Migration[8.0]
  def change
    add_reference :employers, :contact, null: true, foreign_key: { to_table: :employees }
  end
end
