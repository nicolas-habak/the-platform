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

  scope :active, ->(date = Date.current) {
    where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date)
  }

  public

  def to_billing_info(date = Date.today)
    active_policies = division.policies.active(date)
    return {} if active_policies.blank?

    active_policies.each_with_object({}) do |policy, info|
      info[:life] = policy.life if policy.life.present? && life
      if health.in?(%w[single family])
        info[:health_benefit] = health
        info[:health] = policy.public_send("health_#{health}") if policy.public_send("health_#{health}").present?
      end

      if dental.in?(%w[single family])
        info[:dental_benefit] = dental
        info[:dental] = policy.public_send("dental_#{dental}") if policy.public_send("dental_#{dental}").present?
      end
    end
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be after the start date") if end_date <= start_date
  end
end
