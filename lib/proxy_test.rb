class ProxyTest
  include HTTParty
  include ProxyBase
  include ProxyParty

  base_uri 'https://wtfismyip.com'
  format :json

  def self.check_ip
    proxy_request {
      get('/json')
    }
  end

  def self.side_effects
    get('/json')
  end
end

