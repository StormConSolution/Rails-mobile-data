class IosAppWebsite < ActiveRecord::Base
  belongs_to :ios_app
  belongs_to :website
  
end
