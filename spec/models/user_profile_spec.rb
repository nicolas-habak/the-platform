require "rails_helper"

RSpec.describe UserProfile, type: :model do
  let!(:user) { create(:user) }

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it "is valid with all required attributes" do
      profile = build(:user_profile, user: user, first_name: "Jane", last_name: "Doe", sex: "f", date_of_birth: Date.today - 20.years)
      expect(profile).to be_valid
    end

    it "is invalid without a first name" do
      profile = build(:user_profile, first_name: nil)
      expect(profile).not_to be_valid
    end

    it "is invalid without a last name" do
      profile = build(:user_profile, last_name: nil)
      expect(profile).not_to be_valid
    end

    it "validates sex inclusion correctly" do
      expect(build(:user_profile, user: user, sex: "f")).to be_valid
      expect(build(:user_profile, user: user, sex: "m")).to be_valid
      expect(build(:user_profile, user: user, sex: "other")).not_to be_valid
    end

    it "validates presence of date_of_birth" do
      profile = build(:user_profile, date_of_birth: nil)
      expect(profile).not_to be_valid
    end
  end

  describe "#valid_date_of_birth" do
    it "is invalid if date_of_birth is in the future" do
      profile = build(:user_profile, date_of_birth: Date.today + 1.year)
      expect(profile).not_to be_valid
      expect(profile.errors[:date_of_birth]).to include("cannot be in the future")
    end

    it "is valid if date_of_birth is today or in the past" do
      expect(build(:user_profile, user: user, date_of_birth: Date.today)).to be_valid
      expect(build(:user_profile, user: user, date_of_birth: Date.today - 25.years)).to be_valid
    end
  end
end
