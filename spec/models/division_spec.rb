require "rails_helper"

RSpec.describe Division, type: :model do
  let!(:employer) { create(:employer) }
  let!(:other_employer) { create(:employer) }
  let!(:policy) { create(:policy, employer: employer) }
  let!(:invalid_policy) { create(:policy, employer: other_employer) }

  describe "associations" do
    it { should belong_to(:employer) }
    it { should belong_to(:policy).optional }
  end

  describe "validations" do
    it "is valid with an employer and code" do
      division = build(:division, employer: employer, policy: policy, code: "DIV001")
      expect(division).to be_valid
    end

    it "is invalid without an employer" do
      division = build(:division, employer: nil, code: "DIV001")
      expect(division).not_to be_valid
    end

    it "is invalid without a code" do
      division = build(:division, employer: employer, code: nil)
      expect(division).not_to be_valid
    end
  end

  describe "custom validation #policy_employer_matches_division_employer" do
    it "is valid when policy and division share the same employer" do
      division = build(:division, employer: employer, policy: policy)
      expect(division).to be_valid
    end

    it "is invalid when policy and division have different employers" do
      division = build(:division, employer: employer, policy: invalid_policy)
      expect(division).not_to be_valid
      expect(division.errors[:policy]).to include("must belong to the same employer as the division")
    end

    it "is valid when policy is nil" do
      division = build(:division, employer: employer, policy: nil)
      expect(division).to be_valid
    end
  end
end
