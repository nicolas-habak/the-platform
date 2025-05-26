require "rails_helper"

RSpec.describe User, type: :model do
  let!(:user) { create(:user, email: "test@example.com", password: "password123") }
  let!(:role) { create(:role, name: "admin") }
  let!(:user_role) { create(:user_role, user: user, role: role, start_date: Date.today - 1.month, end_date: nil) }

  describe "associations" do
    it { should have_many(:user_profiles).dependent(:destroy) }
    it { should have_many(:user_roles) }
    it { should have_many(:roles).through(:user_roles) }
    it { should have_many(:active_user_roles).class_name("UserRole") }
    it { should have_many(:active_roles).through(:active_user_roles).source(:role) }
  end

  describe "validations" do
    it "is valid with an email and password" do
      expect(build(:user, email: "user@example.com", password: "password")).to be_valid
    end

    it "is invalid without an email" do
      expect(build(:user, email: nil, password: "password")).not_to be_valid
    end

    it "is invalid with an improperly formatted email" do
      expect(build(:user, email: "invalid-email", password: "password")).not_to be_valid
    end

    it "is invalid with a duplicate email (case insensitive)" do
      create(:user, email: "duplicate@example.com", password: "password")
      expect(build(:user, email: "DUPLICATE@example.com", password: "password")).not_to be_valid
    end

    it "is invalid without a password" do
      expect(build(:user, email: "user@example.com", password: nil)).not_to be_valid
    end
  end

  describe "#has_active_role?" do
    it "returns true if the user has an active role on the given date" do
      expect(user.has_active_role?("admin", Date.today)).to be true
    end

    it "returns false if the user does not have the role on the given date" do
      expect(user.has_active_role?("nonexistent_role", Date.today)).to be false
    end

    it "returns false if the role was active in the past but expired" do
      expired_role = create(:role, name: "expired_role")
      create(:user_role, user: user, role: expired_role, start_date: Date.today - 1.year, end_date: Date.today - 6.months)

      expect(user.has_active_role?("expired_role", Date.today)).to be false
    end

    it "returns true if the role was active on a given past date" do
      expect(user.has_active_role?("admin", Date.today - 2.weeks)).to be true
    end

    it "returns false if the role became active after the given date" do
      future_role = create(:role, name: "future_role")
      create(:user_role, user: user, role: future_role, start_date: Date.today + 1.month, end_date: nil)

      expect(user.has_active_role?("future_role", Date.today)).to be false
    end
  end
end
