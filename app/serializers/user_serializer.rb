class UserSerializer < ActiveModel::Serializer
  attributes :id, :email

  has_many :user_profiles
end
