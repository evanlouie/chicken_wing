class Item
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :revision

end
