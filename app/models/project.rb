class Project < ActiveRecord::Base
  has_many :revisions
  has_many :items, through: :revisions
end
