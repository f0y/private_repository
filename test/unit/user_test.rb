require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :projects, :repositories
  context "user" do

    setup do
      @user = User.find(3)
      @dev_role = Role.find(2)
      @project = Project.find(1)
      @repository = @project.repository
    end

    context "in private repository" do
      setup do
        @repository.is_private = true
        @repository.save!
        @project = Project.find(1)
      end

      context "with view_private_repositories permission" do
        setup do
          @dev_role.add_permission!(:view_private_repositories)
          @user = User.find(3)
        end

        should "be allowed to browse_repository" do
          assert @user.allowed_to?(:browse_repository, @project)
        end

        should "be allowed to view_changesets" do
          assert @user.allowed_to?(:view_changesets, @project)
        end

      end

      context "without view_private_repositories permission" do
        setup do
          @dev_role.remove_permission!(:view_private_repositories)
          @user = User.find(3)
        end

        should "not be allowed to browse_repository" do
          assert !@user.allowed_to?(:browse_repository, @project)
        end

        should "not be allowed to view_changesets" do
          assert !@user.allowed_to?(:view_changesets, @project)
        end

        should "not have access to controller actions allowed by browse_repository permission" do
          Redmine::AccessControl.allowed_actions(:browse_repository).each do |path|
            controller, action = path.split(/\//,2)
            assert !@user.allowed_to?({:controller => controller, :action => action}, @project)
          end
        end

        should "not have access to controller actions allowed by view_changesets permission" do
          Redmine::AccessControl.allowed_actions(:view_changesets).each do |path|
            controller, action = path.split(/\//,2)
            assert !@user.allowed_to?({:controller => controller, :action => action}, @project)
          end
        end

      end
    end

    context "in not a private repository" do
      context "without view_private_repositories permission" do
        setup do
          @dev_role.remove_permission!(:view_private_repositories)
          @user = User.find(3)
        end

        should "be allowed to browse_repository" do
          assert @user.allowed_to?(:browse_repository, @project)
        end

        should "be allowed to view_changesets" do
          assert @user.allowed_to?(:view_changesets, @project)
        end

        should "have access to controller actions allowed by browse_repository permission" do
          Redmine::AccessControl.allowed_actions(:browse_repository).each do |path|
            controller, action = path.split(/\//,2)
            assert @user.allowed_to?({:controller => controller, :action => action}, @project)
          end
        end

        should "have access to controller actions allowed by view_changesets permission" do
          Redmine::AccessControl.allowed_actions(:view_changesets).each do |path|
            controller, action = path.split(/\//,2)
            assert @user.allowed_to?({:controller => controller, :action => action}, @project)
          end
        end

      end

    end
  end

end