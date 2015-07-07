# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

web_server = '54.85.3.24'

api_server = '52.6.191.250'

scraper_servers = %w(
  54.164.24.87
  54.88.39.109
  54.86.80.102
)

super_scraper_servers = %w(
  52.7.5.216
)

role :app, [web_server] + scraper_servers + [api_server] + super_scraper_servers
role :web, web_server
role :api, api_server
role :db,  web_server #must have this do migrate db
role :scraper, scraper_servers
role :super_scraper, super_scraper_servers


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server web_server, user: 'deploy'

server api_server, user: 'deploy'

scraper_servers.each do |scraper_server|
  server scraper_server, user: 'deploy'
end

super_scraper_servers.each do |super_scraper_server|
  server super_scraper_server, user: 'deploy'
end

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
 # set :ssh_options, {
 #   keys: ["/Users/hong/.ssh/varys-rooomates"],
 #   keys_only: true
 # }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
