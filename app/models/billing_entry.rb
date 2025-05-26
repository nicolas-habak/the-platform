class BillingEntry < ApplicationRecord
  belongs_to :bill
  belongs_to :insurance_profile
end
