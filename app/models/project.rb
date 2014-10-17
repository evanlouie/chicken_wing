class Project < ActiveRecord::Base
  has_many :revisions
end
