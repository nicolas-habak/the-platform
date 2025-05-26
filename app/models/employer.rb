class Employer < ApplicationRecord
  belongs_to :contact, class_name: "Employee", optional: true

  validates :name, presence: true
end
