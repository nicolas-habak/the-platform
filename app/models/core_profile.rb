class CoreProfile < ApplicationRecord
  belongs_to :employee

  validates :address, presence: true
  validates :salary, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :start_date, presence: true

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
