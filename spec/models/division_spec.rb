require "rails_helper"

RSpec.describe Division, type: :model do
  let!(:employer) { create(:employer) }
  let!(:provider) { create(:provider) }
  let!(:other_employer) { create(:employer) }
  let!(:policy)   { create(:policy, provider: provider, employer: employer) }
  let!(:invalid_policy) { create(:policy, employer: other_employer) }

  let(:billing_period_start) { Date.today }
  let(:billing_period_end) { billing_period_start + 1.month }

  describe "associations" do
    it { should belong_to(:employer) }
    it { should have_and_belong_to_many(:policies) }
  end

  describe "validations" do
    it "is valid with an employer and code" do
      division = build(:division, employer: employer, policies: [ policy ], code: "DIV001")
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
    it "is valid when policies and division share the same employer" do
      division = build(:division, employer: employer, policies: [ policy ])
      expect(division).to be_valid
    end

    it "is invalid when policies and division have different employers" do
      division = build(:division, employer: employer, policies: [ invalid_policy ])
      expect(division).not_to be_valid
      expect(division.errors[:policies]).to include("must belong to the same employer as the division")
    end

    it "is valid when policies is empty" do
      division = build(:division, employer: employer, policies: [])
      expect(division).to be_valid
    end
  end

  describe "#generate_bill" do
    let!(:division) { create(:division, employer: employer, policies: [ policy ], code: "DIV00") }
    let!(:employees) {
      create_list(:employee, 4, employer: employer) do |employee|
        insurance_profile = create(
          :insurance_profile,
          employee: employee,
          start_date: 1.year.ago,
          end_date: nil,
          division: division,
          life: [ true, false ].sample,
          health: [ nil, "single", "family" ].sample,
          dental: [ nil, "single", "family" ].sample
        )
        create(:dependant, insurance_profile: insurance_profile)
      end
    }

    context "when there is no overlapping bill" do
      it "creates a new bill and billing entries" do
        expect {
          division.generate_bill(billing_period_start, billing_period_end)
        }.to change { division.bills.count }.by(1)
         .and change { BillingEntry.count }.by(employees.count)

        new_bill = division.reload.bills.last
        expect(new_bill.date_issued).to eq(Date.today)
        expect(new_bill.billing_period_start).to eq(billing_period_start)
        expect(new_bill.billing_period_end).to eq(billing_period_end)
      end
    end

    context "when there is an overlapping bill" do
      it "raises an error" do
        expect {
          division.generate_bill(billing_period_start, billing_period_end)
          division.generate_bill(billing_period_start, billing_period_end)
        }.to raise_error(RuntimeError, /Billing Period overlap/)
      end
    end

    context "when a transaction fails" do
      before do
        allow(division).to receive(:insurance_profiles).and_raise(StandardError, "Test failure")
      end

      it "does not create a bill" do
        expect {
          division.generate_bill(billing_period_start, billing_period_end) rescue nil
        }.not_to change { division.reload.bills.count }
      end
    end
  end
end
