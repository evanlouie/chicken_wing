class Revision < ActiveRecord::Base
  belongs_to :project
  has_many :items
end
