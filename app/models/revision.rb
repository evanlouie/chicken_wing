class Revision
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :project
  embeds_many :items

end
