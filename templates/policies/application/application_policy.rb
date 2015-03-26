class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    user.admin? || scoped?
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    user.admin? || scoped?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || scoped?
  end

  def destroy_all?
    user.admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def scoped?
    scope.where(id: record.id).exists?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.admin? ? scope.all : scope.where(user_id: @user)
    end

  end
end


