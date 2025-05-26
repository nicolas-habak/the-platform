class UserProfile < ApplicationRecord
  belongs_to :user

  validates :first_name, :last_name, presence: true
  validates :sex, inclusion: { in: %w[f m], message: "must be either 'f' or 'm'" }
  validates :date_of_birth, presence: true
  validate :valid_date_of_birth

  private

  def valid_date_of_birth
    return if date_of_birth.blank?

    if date_of_birth > Date.today
      errors.add(:date_of_birth, "cannot be in the future")
    end
  end
end
