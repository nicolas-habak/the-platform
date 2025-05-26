class Provider < ApplicationRecord
  has_many :policies, dependent: :destroy

  validates :name, :address, :phone, presence: true
  validates :phone, format: { with: /\A\+?\d{10,15}\z/, message: "should be a valid phone number" }
end
