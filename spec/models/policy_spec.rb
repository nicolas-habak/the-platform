require "rails_helper"

RSpec.describe Policy, type: :model do
  let!(:provider) { create(:provider) }
  let!(:employer) { create(:employer) }

  describe "associations" do
    it { should belong_to(:provider) }
    it { should belong_to(:employer) }
  end

  describe "validations" do
    it "is valid with all required attributes" do
      policy = build(:policy, provider: provider, employer: employer, number: "P12345", start_date: Date.today, end_date: Date.today + 1.day)
      expect(policy).to be_valid
    end

    it "is invalid without a number" do
      policy = build(:policy, provider: provider, employer: employer, number: nil)
      expect(policy).not_to be_valid
    end

    it "validates numericality of coverage attributes correctly" do
      expect(build(:policy, life: 100, health_single: 200, health_family: 300, dental_single: 50, dental_family: 150)).to be_valid
      expect(build(:policy, life: -1)).not_to be_valid
    end
  end

  describe "#end_date_required_if_started" do
    it "is valid when start_date is today or in the past and end_date is present" do
      policy = build(:policy, start_date: Date.today - 1.month, end_date: Date.today + 1.month)
      expect(policy).to be_valid
    end

    it "is invalid when start_date is today or in the past and end_date is blank" do
      policy = build(:policy, start_date: Date.today - 1.month, end_date: nil)
      expect(policy).not_to be_valid
      expect(policy.errors[:end_date]).to include("must be present if start date is today or in the past")
    end

    it "is valid when start_date is in the future, even if end_date is blank" do
      policy = build(:policy, start_date: Date.today + 1.month, end_date: nil)
      expect(policy).to be_valid
    end
  end
end
