require "rails_helper"

RSpec.describe Dependant, type: :model do
  let!(:employer) { create(:employer) }
  let!(:provider) { create(:provider) }
  let!(:policy)   { create(:policy, provider: provider, employer: employer) }
  let!(:division) { create(:division, :with_policies, employer: employer) }
  let!(:employee) { create(:employee, employer: employer) }
  let!(:insurance_profile) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_inclusion_of(:relation).in_array(%w[child spouse]).with_message("must be either 'child' or 'spouse'") }

    it "is valid when has_disability is true or false" do
      expect(build(:dependant, has_disability: true)).to be_valid
      expect(build(:dependant, has_disability: false)).to be_valid
    end

    it "is invalid when has_disability is nil" do
      expect(build(:dependant, has_disability: nil)).not_to be_valid
    end

  end

  describe "valid relation values" do
    it "is valid when relation is 'child' or 'spouse'" do
      expect(build(:dependant, relation: "child")).to be_valid
      expect(build(:dependant, relation: "spouse")).to be_valid
    end

    it "is invalid for any other relation value" do
      expect(build(:dependant, relation: "parent")).not_to be_valid
      expect(build(:dependant, relation: nil)).not_to be_valid
    end
  end

  describe "disability validation" do
    it "is valid when has_disability is true or false" do
      expect(build(:dependant, has_disability: true)).to be_valid
      expect(build(:dependant, has_disability: false)).to be_valid
    end

    it "is invalid when has_disability is nil" do
      expect(build(:dependant, has_disability: nil)).not_to be_valid
    end
  end
end
