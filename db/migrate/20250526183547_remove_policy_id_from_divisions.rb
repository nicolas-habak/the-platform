class RemovePolicyIdFromDivisions < ActiveRecord::Migration[8.0]
  def change
    remove_column :divisions, :policy_id, :integer
  end
end
