class CreateJoinTableDivisionsPolicies < ActiveRecord::Migration[8.0]
  def change
    create_join_table :divisions, :policies do |t|
      t.index [ :division_id, :policy_id ]
      t.index [ :policy_id, :division_id ]
    end
  end
end
