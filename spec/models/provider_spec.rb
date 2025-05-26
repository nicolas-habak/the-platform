require "rails_helper"

RSpec.describe Provider, type: :model do
  describe "associations" do
    it { should have_many(:policies).dependent(:destroy) }
  end

  describe "validations" do
    it "is valid with a name, address, and phone" do
      provider = build(:provider, name: "Health Insurance Co.", address: "456 Main Street", phone: "+1234567890")
      expect(provider).to be_valid
    end

    it "is invalid without a name" do
      provider = build(:provider, name: nil, address: "456 Main Street", phone: "+1234567890")
      expect(provider).not_to be_valid
    end

    it "is invalid without an address" do
      provider = build(:provider, name: "Health Insurance Co.", address: nil, phone: "+1234567890")
      expect(provider).not_to be_valid
    end

    it "is invalid without a phone number" do
      provider = build(:provider, name: "Health Insurance Co.", address: "456 Main Street", phone: nil)
      expect(provider).not_to be_valid
    end

    it "is valid with a correctly formatted phone number" do
      expect(build(:provider, phone: "+1234567890")).to be_valid
      expect(build(:provider, phone: "123456789012")).to be_valid
    end

    it "is invalid with an incorrectly formatted phone number" do
      expect(build(:provider, phone: "abc123")).not_to be_valid
      expect(build(:provider, phone: "123")).not_to be_valid
      expect(build(:provider, phone: "+1234567890123456")).not_to be_valid
    end
  end
end
