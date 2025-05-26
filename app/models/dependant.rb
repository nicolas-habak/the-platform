class Dependant < ApplicationRecord
  belongs_to :insurance_profile

  validates :name, :date_of_birth, presence: true
  validates :relation, inclusion: { in: %w[child spouse],
                                    message: "must be either 'child' or 'spouse'" }
  validates :has_disability, inclusion: { in: [ true, false ] }
end
