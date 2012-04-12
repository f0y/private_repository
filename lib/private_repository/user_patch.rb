module PrivateRepository
  module UserPatch

    class << self
      attr_accessor :intercepted_actions
    end

    def self.included(base)
      @intercepted_actions = Set.new(Redmine::AccessControl.allowed_actions(:browse_repository).
          concat(Redmine::AccessControl.allowed_actions(:view_changesets)).collect { |path|
        controller, action = path.split(/\//, 2)
        {:controller => controller, :action => action}
      })

      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :allowed_to?, :private_repository
      end
    end
  end

  module InstanceMethods

    def allowed_to_with_private_repository?(action, context, options={}, &block)
      if (:browse_repository == action || :view_changesets == action) or
          (action.is_a?(Hash) && PrivateRepository::UserPatch.intercepted_actions.include?(action)) and
              context && context.is_a?(Project) and
              context.repository && context.repository.is_private
        unless allowed_to?(:view_private_repositories, context, options, &block)
          return false
        end
      end
      allowed_to_without_private_repository?(action, context, options, &block)
    end

  end

end