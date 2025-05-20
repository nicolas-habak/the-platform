class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :token

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :token, unique: true
  end
end
