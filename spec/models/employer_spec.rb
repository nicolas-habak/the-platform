require "rails_helper"

RSpec.describe Employer, type: :model do
  describe "associations" do
    it { should belong_to(:contact).class_name("Employee").optional }
  end

  describe "validations" do
    it "is valid with a name and an address" do
      employer = build(:employer, name: "Tech Corp", address: "123 Main Street")
      expect(employer).to be_valid
    end

    it "is invalid without a name" do
      employer = build(:employer, name: nil, address: "123 Main Street")
      expect(employer).not_to be_valid
    end

    it "is valid without an address" do
      employer = build(:employer, name: "Tech Corp", address: nil)
      expect(employer).to be_valid
    end
  end
end
