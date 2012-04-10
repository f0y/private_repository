module PrivateRepository
  module ChangesetPatch

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        unloadable
        class << self
          alias_method_chain :find_events, :private_repository
        end
      end
    end

    module ClassMethods

      def find_events_with_private_repository(event_type, user, from, to, options)
        changesets = find_events_without_private_repository(event_type, user, from, to, options)
        changesets.select do |changeset|
          user.allowed_to?(:view_changesets, changeset.project)
        end
      end
    end

  end
end
