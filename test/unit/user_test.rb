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

    context "private repository" do
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
      end
    end

    context "not a private repository" do
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

      end

    end
  end

end