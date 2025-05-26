class Employee < ApplicationRecord
  belongs_to :employer

  has_many :insurance_profiles
  has_many :core_profiles

  validates :sex, inclusion: { in: %w[f m], message: "must be either 'f' or 'm'" }
  validate :unique_insurance_profile_start_dates

  private

  def unique_insurance_profile_start_dates
    duplicate_dates = insurance_profiles.group(:start_date).having("COUNT(*) > 1").pluck(:start_date)

    if duplicate_dates.any?
      errors.add(:insurance_profiles, "cannot have duplicate start dates: #{duplicate_dates.join(', ')}")
    end
  end

  public


  def fix_insurance_profile_timeline
    fix_profile_timeline(insurance_profiles.order(start_date: :desc))
  end

  def fix_core_profile_timeline
    fix_profile_timeline(core_profiles.order(start_date: :desc))
  end

  def fix_profile_timeline(profiles)
    profiles.each do |current_profile|
      profiles.where("end_date >= ? OR end_date IS NULL", current_profile.start_date).each do |previous_profile|
        previous_profile.update(end_date: 1.day.before(current_profile.start_date))
      end
    end
  end
end
