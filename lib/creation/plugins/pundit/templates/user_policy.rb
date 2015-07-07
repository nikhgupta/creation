class <%= options[:admin_user].camelize %>Policy < ApplicationPolicy

  def index?
    <%= options[:admin_user].underscore %>.admin?
  end

  def create?
    <%= options[:admin_user].underscore %>.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      <%= options[:admin_user].underscore %>.admin? ? scope.all : scope.where(id: @<%= options[:admin_user].underscore %>)
    end
  end
end
