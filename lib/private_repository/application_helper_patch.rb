require_dependency 'application_helper'

module PrivateRepository
  module ApplicationHelperPatch

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        #unloadable
        # I commented out "unloadable" statement in order to run the plugin in development mode.
        # If this statement is not commented out then fails occurs after loading any page.
        # The consequence is that this module does not loaded in development mode,
        # but fully operational in production.
        alias_method_chain :parse_redmine_links, :private_repository
      end
    end


    module InstanceMethods
      def parse_redmine_links_with_private_repository(text, project, obj, attr, only_path, options)
        result = nil
        text.gsub(%r{([\s\(,\-\[\>]|^)(!)?(([a-z0-9\-]+):)?(attachment|document|version|forum|news|commit|source|export|message|project)?((#|r)(\d+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|,|\s|\]|<|$)}) do |m|
          leading, esc, project_prefix, project_identifier, prefix, sep, identifier = $1, $2, $3, $4, $5, $7 || $9, $8 || $10
          if esc.nil?
            if prefix.nil? && sep == 'r'
              unless project && project.repository &&
                    (changeset = Changeset.visible.find_by_repository_id_and_revision(project.repository.id, identifier)) &&
                    User.current.allowed_to?(:view_changesets, project)
                result = (leading + "#{project_prefix}#{prefix}#{sep}#{identifier}").html_safe
              end
            elsif sep == ':' && prefix == 'commit'
              unless project && project.repository &&
                    (changeset = Changeset.visible.find(:first, :conditions => ["repository_id = ? AND scmid LIKE ?", project.repository.id, "#{name}%"])) &&
                    User.current.allowed_to?(:view_changesets, project)
                result = (leading + "#{project_prefix}#{prefix}#{sep}#{identifier}").html_safe
              end
            end
          end
        end
        parse_redmine_links_without_private_repository(text, project, obj, attr, only_path, options) unless result
      end
    end
  end
end