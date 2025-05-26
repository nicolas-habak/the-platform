class DivisionPolicy < ApplicationPolicy

  def index?
    user.has_active_role?(%w[admin actuary])
  end

  def show?
    user.has_active_role?(%w[admin actuary])
  end

  def create?
    user.has_active_role?(%w[admin actuary])
  end

  def update?
    user.has_active_role?(%w[admin actuary])
  end

  def destroy?
    user.has_active_role?("admin")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_active_role?(%w[admin actuary])
        scope.all
      else
        scope.none
      end
    end
  end
end
