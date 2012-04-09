module PrivateRepository
  module RepositoriesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      protected_actions = [:show, :browse, :entry, :annotate, :changes, :diff, :stats, :graph, :revisions, :revision]
      base.before_filter :forbid_access_to_private_repository,
                         :only => protected_actions
    end
  end

  module InstanceMethods
    def forbid_access_to_private_repository
      if @repository.is_private? && !User.current.allowed_to?(:view_private_repositories, @project)
        render_403
      else
        true
      end
    end
  end

end