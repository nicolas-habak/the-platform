class Division < ApplicationRecord
  belongs_to :employer
  belongs_to :policy, optional: true

  validates :employer, :code, presence: true

  validate :policy_employer_matches_division_employer

  private

  def policy_employer_matches_division_employer
    if policy.present? && employer.present? && policy.employer != employer
      errors.add(:policy, "must belong to the same employer as the division")
    end
  end
end
