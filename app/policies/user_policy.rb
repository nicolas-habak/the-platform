class UserPolicy < ApplicationPolicy
  def index?
    user.has_active_role?("admin")
  end

  def show?
    user.has_active_role?("admin") || user.id == record.id
  end

  def create?
    user.has_active_role?("admin")
  end

  def update?
    user.has_active_role?("admin") || user.id == record.id
  end

  def destroy?
    user.has_active_role?("admin")
  end

  def permitted_attributes
    [:email, :password]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # For example, admin sees all users, while others might see none.
      if user.has_active_role?("admin")
        scope.all
      else
        scope.none
      end
    end
  end
end