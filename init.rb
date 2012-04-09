require 'redmine'

require 'private_repository/repositories_helper_patch'
require 'dispatcher'

Dispatcher.to_prepare :redmine_private_repository do
  unless RepositoriesHelper.included_modules.include? PrivateRepository::RepositoriesHelperPatch
    RepositoriesHelper.send(:include, PrivateRepository::RepositoriesHelperPatch)
  end
  unless RepositoriesController.included_modules.include? PrivateRepository::RepositoriesControllerPatch
    RepositoriesController.send(:include, PrivateRepository::RepositoriesControllerPatch)
  end
end


Redmine::Plugin.register :redmine_private_repository do
  name 'Private Repository'
  author 'Oleg Kandaurov'
  description 'Adds ability to mark repositories as private.'
  version '0.0.1'
  author_url 'http://okandaurov.info'

  project_module :repository do
    permission :view_private_repositories, {}
  end

end
