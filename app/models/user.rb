class User < ApplicationRecord
  has_secure_password
  has_secure_token

  has_many :user_profiles, dependent: :destroy
end
