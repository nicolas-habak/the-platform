class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :sex, :date_of_birth, :created_at, :updated_at
end
