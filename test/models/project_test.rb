require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "required attributes" do
    project = Project.new
    assert_not project.save, "required attributes not set"
  end

  test "must have a revision" do
    project = Project.new
    assert project.revisions.size == 0, "project revision miscount: expected 0, got #{project.revisions.size}"
    for i in 1..100 do
      project.revisions.new
    end
    assert project.revisions.size == 100, "project revision miscount: expected 100, got #{project.revisions.size}"
  end

  test "name generator" do
    project = Project.new
    project.git="https://github.com/github/markup.git"
    assert project.save, "name was not automatically generated, name is currently: #{project.name}"
    project.destroy!
  end

  test "delete project files" do
    project = Project.new
    project.git="https://github.com/evanlouie/chicken_wing.git"
    project.save!
    project.destroy!
    assert_not File.directory?(project.dir), "project files still exist after destroy! dir: #{project.dir}"
  end
  
end
