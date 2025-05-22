class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  scope :active, ->(date = Date.current) do
    where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date)
  end
end
