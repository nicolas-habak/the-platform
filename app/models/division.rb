class Division < ApplicationRecord
  belongs_to :employer
  has_and_belongs_to_many :policies

  has_many :bills
  has_many :insurance_profiles

  validates :employer, :code, presence: true

  validate :policy_employer_matches_division_employer

  public
  def generate_bill(billing_period_start = Date.today, billing_period_end = nil)
    if billing_period_end.blank?
      billing_period_end = 1.month.billing_period_start
    end

    overlapping_bills = bills.where(
      "billing_period_start <= ? AND billing_period_end >= ? OR billing_period_start <= ? AND billing_period_end >= ?",
      billing_period_start, billing_period_start, billing_period_end, billing_period_end)

    if overlapping_bills.empty?
      ActiveRecord::Base.transaction do
        bill = bills.create!(date_issued: Date.today, billing_period_start: billing_period_start, billing_period_end: billing_period_end)
        insurance_profiles.active(billing_period_start).each do |profile|
          bill.billing_entries.create!(insurance_profile: profile, **profile.to_billing_info(billing_period_start))
          bill.valid?
        end
      end
    else
      raise "Billing Period overlap with #{overlapping_bills.pluck(:id)}"
    end
  end

  private

  def policy_employer_matches_division_employer
    if !employer.blank? and !policies.select { |policy| policy.employer_id != employer.id }.empty?
      errors.add(:policies, "must belong to the same employer as the division")
    end
  end
end
