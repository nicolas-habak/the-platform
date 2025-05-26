require "rails_helper"

RSpec.describe CoreProfile, type: :model do
  let!(:employee) { create(:employee) }

  describe "validations" do
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:salary) }
    it { should validate_numericality_of(:salary).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:start_date) }
  end

  describe "custom validation #end_date_after_start_date" do
    it "is valid when end_date is after start_date" do
      profile = build(:core_profile, start_date: Date.today, end_date: Date.today + 1.month)
      expect(profile).to be_valid
    end

    it "is invalid when end_date is before start_date" do
      profile = build(:core_profile)
      profile.update(start_date: Date.today)
      profile.update(end_date: 1.day.before(Date.today))

      expect(profile).not_to be_valid
      expect(profile.errors[:end_date]).to include("must be after the start date")
    end

    it "is valid when end_date is nil" do
      profile = build(:core_profile, start_date: Date.today, end_date: nil)
      expect(profile).to be_valid
    end
  end
end
