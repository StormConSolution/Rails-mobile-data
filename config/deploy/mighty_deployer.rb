module MightyDeployer

  @app_roles = []
  @web_roles = []
  @api_roles = []
  @db_roles = []
  @sdk_scraper_roles = []
  @scraper_roles = []
  
  @web_servers = []
  @api_servers = []
  @scraper_servers = []
  @sdk_scraper_servers = []

  def self.deploy_to(server_symbols)
    valid_symbols = [:web_api, :scraper, :sdk_scraper]
    
    raise "Input an array with a combination of these values: #{valid_symbols}" unless (server_symbols - valid_symbols).empty?
    
    define_web_api_servers if server_symbols.include?(:web_api)
    define_scraper_servers if server_symbols.include?(:scraper)
    define_sdk_scraper_servers if server_symbols.include?(:sdk_scraper)
    
    define_roles
    
    set_users
  end

  def self.define_web_api_servers
    @web_servers = %w(
      54.85.3.24
    )

    @api_servers = %w(
      52.6.191.250
    )
  
    @app_roles += @web_servers + @api_servers
    @web_roles += @web_servers
    @db_roles += @web_servers
    @api_roles += @api_servers
  
  end

  def self.define_scraper_servers
    @scraper_servers = %w(
      52.2.192.44
    )
  
    @app_roles += @scraper_servers
    @scraper_roles += @scraper_servers
  end

  def self.define_sdk_scraper_servers
    @sdk_scraper_servers = %w(
      54.164.24.87
      54.88.39.109
      54.86.80.102
    )
  
    @app_roles += @sdk_scraper_servers
    @sdk_scraper_roles += @sdk_scraper_servers
  end

  private

  def self.define_roles
    puts "@app_roles: #{@app_roles}"
    
    role :app, @app_roles
    role :web, @web_roles
    role :api, @api_roles
    role :db,  @db_roles #must have this do migrate db
    role :sdk_scraper, @sdk_scraper_roles
    role :scraper, @scraper_roles
  end
  
  def self.set_users
    @web_servers.each do |web_server|
      server web_server, user: 'deploy'
    end
    
    @api_servers.each do |api_server|
      server api_server, user: 'deploy'
    end
    
    @scraper_servers.each do |scraper_server|
      server scraper_server, user: 'deploy'
    end
    
    @sdk_scraper_servers.each do |sdk_scraper_server|
      server sdk_scraper_server, user: 'deploy'
    end
    
  end


  
end