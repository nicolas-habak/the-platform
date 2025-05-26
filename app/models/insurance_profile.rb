class InsuranceProfile < ApplicationRecord
  belongs_to :employee
  belongs_to :division

  validates :life, :smoker, inclusion: { in: [ true, false ], message: "must be true or false" }, exclusion: { in: [nil] }

  validates :health, inclusion: { in: %w[single family], allow_blank: true,
                                  message: "must be either 'single', 'family', or blank" }
  validates :dental, inclusion: { in: %w[single family], allow_blank: true,
                                  message: "must be either 'single', 'family', or blank" }

  validates :start_date, presence: true
  validate :end_date_after_start_date

  scope :active, -> {
    where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", Date.today, Date.today)
  }

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be after the start date") if end_date <= start_date
  end
end
