class User < ApplicationRecord
  has_secure_password
  has_secure_token

  has_many :user_profiles, dependent: :destroy

  has_many :user_roles
  has_many :roles, through: :user_roles

  has_many :active_user_roles, -> { active }, class_name: "UserRole"
  has_many :active_roles, through: :active_user_roles, source: :role

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, presence: true

  public

  def has_active_role?(role_name, date = Date.today)
    active_user_roles.active(date).joins(:role).where(roles: { name: role_name }).exists?
  end

  def regenerate_token
    update_attribute(:token, SecureRandom.hex(20))
  end
end
