class ListablesList < ActiveRecord::Base
  
  belongs_to :listable, polymorphic: true
  belongs_to :list
  
end
