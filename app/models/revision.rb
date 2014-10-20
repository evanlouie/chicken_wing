class Revision
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :project
  embeds_many :items
end
