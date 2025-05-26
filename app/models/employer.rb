class Employer < ApplicationRecord
  belongs_to :contact, class_name: "Employee", optional: true
  has_many :employees

  has_many :divisions

  validates :name, presence: true

  def generate_bill(date = Date.today)
    ActiveRecord::Base.transaction do
      divisions.each do |division|
        division.generate_bill(date)
      end
    end
  end
end
