require "rails_helper"

RSpec.describe Employee, type: :model do
  let!(:employer) { create(:employer) }
  let!(:provider) { create(:provider) }
  let!(:policy)   { create(:policy, provider: provider, employer: employer) }
  let!(:division) { create(:division, :with_policies, employer: employer) }
  let!(:employee) { create(:employee, employer: employer) }

  describe "validations" do
    it { should validate_inclusion_of(:sex).in_array(%w[f m]).with_message("must be either 'f' or 'm'") }

    context "when employee has duplicate insurance profile start dates" do

      let!(:insurance_profile1) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today)
      }
      let!(:insurance_profile2) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today) }

      it "raises a validation error" do
        expect(employee.valid?).to be_falsey
        expect(employee.errors[:insurance_profiles]).to include("cannot have duplicate start dates: #{Date.today}")
      end
    end
  end

  describe "#fix_insurance_profile_timeline" do
    let!(:insurance_profile1) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today - 1.month, end_date: nil) }
    let!(:insurance_profile2) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today, end_date: Date.today + 2.month) }
    let!(:insurance_profile3) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today + 1.month, end_date: nil) }

    it "adjusts the end dates correctly" do
      expect {
        employee.fix_insurance_profile_timeline
      }.to change { insurance_profile1.reload.end_date }.from(nil).to(insurance_profile2.start_date - 1.day)
       .and change { insurance_profile2.reload.end_date }.from(Date.today + 2.month).to(insurance_profile3.start_date - 1.day)

      expect(insurance_profile3.reload.end_date).to be_nil
    end

  end
end
