class Project
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embeds_many :revisions

  field :git
  field :name
  field :dir
end
