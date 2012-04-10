require File.dirname(__FILE__) + '/../test_helper'

class ChangesetTest < ActiveSupport::TestCase

  fixtures :projects, :repositories, :issues, :issue_statuses, :issue_categories, :changesets, :changes,
           :enumerations, :custom_fields, :custom_values, :users, :members, :member_roles, :trackers,
           :enabled_modules, :roles

  context "changeset in private repository" do
    setup do
      @user = User.find(3)
      @dev_role = Role.find(2)
      @project = Project.find(1)
      repository = @project.repository
      repository.is_private = true
      repository.save!
      @project = Project.find(1)
    end

    should "not return changesets without view_private_repositories permission" do
      @dev_role.remove_permission!(:view_private_repositories)
      @user = User.find(3)
      e = Changeset.find_events('changesets', @user, Date.new(2000, 12, 22), Date.today,
                                {:project => @project, :author => nil,
                                 :with_subprojects => true, :limit => nil})
      assert e.empty?
    end

    should "return changesets if user has view_private_repositories permission" do
      @dev_role.add_permission!(:view_private_repositories)
      @user = User.find(3)
      e = Changeset.find_events('changesets', @user, Date.new(2000, 12, 22), Date.today,
                                {:project => @project, :author => nil,
                                 :with_subprojects => true, :limit => nil})
      assert !e.empty?
    end

  end
end