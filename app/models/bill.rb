class Bill < ApplicationRecord
  belongs_to :division
  has_many :billing_entries, dependent: :destroy
end
