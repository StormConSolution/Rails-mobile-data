source 'https://rubygems.org'

# Lor San Tekka needs to be added as a user on any private MightySignal repos you use

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.8'
# Use mysql as the database for Active Record
gem 'mysql2', '0.3.17'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', '~> 0.12.3'

gem 'slim', '3.0.6'
gem 'slim-rails', '3.0.1'

# required for asset pipeline
# for middleman/turbolinks
# http://guides.rubyonrails.org/asset_pipeline.html
gem 'sass-rails'

# The most popular HTML, CSS, and JavaScript framework for developing responsive, mobile first projects on the web. http://getbootstrap.com
# gem 'bootstrap', '4.3.0'
gem 'autoprefixer-rails', '9.4.8'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem 'jquery-turbolinks' #for $(document).ready

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', '1.3.6',       group: :development

gem 'whenever', '0.9.4', require: false

gem 'nokogiri', '1.6.4.1'
gem "recaptcha", '4.0.1', require: "recaptcha/rails"
gem 'andand'

# for deployment
group :development do
  gem 'annotate'
  gem 'capistrano', '3.4.0'
  gem 'capistrano-rails', '1.1.2'
  gem 'capistrano-rvm', '0.1.2'
  gem 'capistrano-sidekiq-mighty-servers', github: 'MightySignal/capistrano-sidekiq-mighty-servers', branch: 'select_queues_per_server'
end

# allow http to https redirections
gem 'open_uri_redirections', require: "open_uri_redirections"

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn', '4.9.0', group: :production

gem 'spidr', '0.4.1'

gem 'PageRankr', '4.2.1'

gem 'newrelic_rpm'

gem 'restforce', '2.5.3'
gem 'metaforce', '~> 1.0.8', git: 'https://11eba4fe4c8c978205e15b6553a02f82a35bed67:x-oauth-basic@github.com/MightySignal/metaforce.git'
gem 'omniauth-salesforce'
gem 'salesforce_bulk_api', github: 'yatish27/salesforce_bulk_api'

gem 'httparty', '0.13.7'
gem 'httpclient'
gem 'countries'

source "https://ee3069b7:c6ce5996@gems.contribsys.com/" do
  gem 'sidekiq-pro', '~> 3.4.1'
end
gem 'sidekiq-throttler', '0.5.1'

gem 'sinatra', '~> 1.0', :require => false

gem 'filesize', '0.0.4'

gem 'socksify', '1.6.0', require: 'socksify/http'

gem 'net-ssh', '~> 4.0'

gem 'kaminari', '0.16.3'

gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'

gem 'jwt', '1.0.0'

#cors
gem 'rack-cors', require: 'rack/cors'

gem 'bcrypt', '3.1.10'

gem 'text', '1.3.1'

gem 'iso_country_codes', '0.7.1'

gem 'bugsnag', '~>5.3.2'

gem 'ruby_apk', git: 'https://11eba4fe4c8c978205e15b6553a02f82a35bed67:x-oauth-basic@github.com/MightySignal/ruby_apk.git', branch: 'use_rubyzip_v_1_1_7'

gem 'sanitize', '4.0.0'

gem 'net', require: 'net/http'

gem 'mixpanel-ruby', '2.1.0', require: 'mixpanel-ruby'

gem 'domainatrix', github: 'mhui/domainatrix'

gem 'parallel', '1.6.0'

gem 'clearbit'

gem 'slackiq', '1.1.4'

gem 'www-favicon', '0.0.6'

gem 'elasticsearch-rails', '0.1.7'
gem 'elasticsearch-model', '0.1.7'

gem "redis-rails"
gem 'actionpack-action_caching', git: "https://github.com/rails/actionpack-action_caching.git", branch: "master"

gem 'chewy', '0.8.4'

gem 'paperclip', '~>5.0.0.beta2'

gem 'mighty_aws', git: 'https://11eba4fe4c8c978205e15b6553a02f82a35bed67:x-oauth-basic@github.com/MightySignal/mighty_aws.git', tag: '0.9.1'

gem 'colorize', '0.7.7'

gem 'awesome_print', '1.6.1'

gem 'rubyzip', '1.1.7'

gem 'diff_dirs', '0.1.2'

gem 'seed_dump'

# for sitemap gen
gem 'sitemap_generator'

# for browser detection
gem 'browser', '2.5.2'

gem 'fuzzy_match', '2.1.0'

# for mass inserts
gem 'activerecord-import', '0.13.0'

# for mighty bot
gem 'twitter', '5.16.0'
gem 'googl', '0.7.1'

# for mightyapk's protocol buffer
gem 'ruby-protocol-buffers', '~>1.6.1'

# for JSON logs
gem 'lograge', '~> 0.4.1'
# for mixpanel analytics
gem 'mixpanel_client', '4.1.5'
gem 'ahoy_matey'

# for customer success url generation
gem 'addressable', '~>2.4'

gem 'simplecov', '~>0.15.1', :require => false, :group => :test


group :development, :test do
  gem 'timecop'
  gem "mocha", '~> 1.3.0'
  # for non-Docker local development
  gem 'dotenv-rails', '~>2.1.1'
  gem 'rubocop'
  gem 'byebug'
end

group :test do
  gem 'rspec-rails', '~> 3.8'
  gem 'minitest', '~> 5.1'
  gem 'database_cleaner'
end

group :development, :staging, :test do
  gem 'factory_girl_rails'
end

# for manipulate IPA plists
gem 'plist', '~> 3.2'

# for throttling. Let Sidekiq handle version locking
gem 'redis'

# for API docs
gem 'middleman', '~>4.2.1'
gem 'middleman-syntax', '~> 3.0.0'
gem 'middleman-autoprefixer', '~> 2.10.0'
gem "middleman-sprockets", "~> 4.1.0"
gem 'rouge', '~> 2.0.5'
gem 'redcarpet', '~> 3.4.0'

# for redshift connections
gem 'activerecord4-redshift-adapter', '~> 0.2.4', git: 'https://11eba4fe4c8c978205e15b6553a02f82a35bed67:x-oauth-basic@github.com/MightySignal/activerecord4-redshift-adapter.git'

gem 'pg', '~> 0.21'

gem 'healthy_pools', '2.2.5'

# Butter is a blogging platform. See https://buttercms.com for details.
gem 'buttercms-rails'
