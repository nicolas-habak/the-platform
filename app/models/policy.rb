class Policy < ApplicationRecord
  belongs_to :provider
  belongs_to :employer

  validates :number, presence: true
  validates :life, :health_single, :health_family, :dental_single, :dental_family,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  validate :end_date_required_if_started

  private

  def end_date_required_if_started
    if start_date.present? && start_date <= Date.today && end_date.blank?
      errors.add(:end_date, "must be present if start date is today or in the past")
    end
  end
end
