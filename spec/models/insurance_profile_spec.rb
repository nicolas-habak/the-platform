require "rails_helper"

RSpec.describe InsuranceProfile, type: :model do
  let!(:employer) { create(:employer) }
  let(:employee) { create(:employee) }
  let!(:policy) { create(:policy, employer: employer) }
  let!(:division) { create(:division, :with_policies, employer: employer) }

  describe "associations" do
    it { should belong_to(:employee) }
    it { should belong_to(:division) }
  end

  describe "validations" do
    it "is valid with required attributes" do
      profile = build(:insurance_profile, employee: employee, division: division, life: true, smoker: false, start_date: Date.today)
      expect(profile).to be_valid
    end

    it "is invalid without a start_date" do
      profile = build(:insurance_profile, start_date: nil)
      expect(profile).not_to be_valid
    end

    it "validates life and smoker inclusion correctly" do
      expect(build(:insurance_profile, life: true, smoker: false)).to be_valid
      expect(build(:insurance_profile, life: nil, smoker: nil)).not_to be_valid
    end

    it "validates health and dental options correctly" do
      expect(build(:insurance_profile, health: "single", dental: "family")).to be_valid
      expect(build(:insurance_profile, health: "invalid", dental: "invalid")).not_to be_valid
      expect(build(:insurance_profile, health: nil, dental: nil)).to be_valid
    end
  end

  describe "#end_date_after_start_date" do
    it "is valid when end_date is after start_date" do
      profile = build(:insurance_profile, start_date: Date.today, end_date: Date.today + 1.month)
      expect(profile).to be_valid
    end

    it "is invalid when end_date is before start_date" do
      profile = build(:insurance_profile, start_date: Date.today, end_date: Date.today - 1.day)
      expect(profile).not_to be_valid
      expect(profile.errors[:end_date]).to include("must be after the start date")
    end

    it "is valid when end_date is nil" do
      profile = build(:insurance_profile, start_date: Date.today, end_date: nil)
      expect(profile).to be_valid
    end
  end

  describe ".active scope" do
    let!(:past_profile) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today - 1.year, end_date: Date.today - 1.month) }
    let!(:current_profile) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today - 1.month, end_date: nil) }
    let!(:future_profile) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today + 1.month, end_date: nil) }

    it "returns only active insurance profiles" do
      expect(InsuranceProfile.active).to contain_exactly(current_profile)
    end
  end
end
