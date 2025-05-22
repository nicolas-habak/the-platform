class User < ApplicationRecord
  has_secure_password
  has_secure_token

  has_many :user_profiles, dependent: :destroy

  has_many :user_roles
  has_many :roles, through: :user_roles

  has_many :active_user_roles, -> { active }, class_name: "UserRole"
  has_many :active_roles, through: :active_user_roles, source: :role

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def has_active_role?(role_name)
    active_roles.where(name: role_name).exists?
  end
end
