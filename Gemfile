source 'https://rubygems.org'

# To support HTTPS in gems coming from GitHub repositories
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.3'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'


# MySQL - default database (in dev and production)
gem 'mysql2', '~> 0.4.6'

# Active admin
gem 'activeadmin', '~> 1.0.0', github: 'activeadmin'
gem 'inherited_resources', '~> 1.7.2', github: 'activeadmin/inherited_resources'
gem 'enumerize', '~> 2.1.2' # for roles


# PDF processing
gem 'pdf-reader', '~> 2.0.0'

# Image processing 
gem 'mini_magick', '~> 4.7.0' # for image processing, better memory footprint than RMagick
gem 'ruby-vips', '~> 1.0.5' # for tiling and fast image processing
gem 'fastimage', '~> 2.1.0' # to get image sizes fast


# Upload processing
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave', tag: 'v0.10.0'
gem 'fog-aws', '~> 1.3.0' # can be changed to 'fog' or another source, to support other cloud storage providers
gem 'parallel', '~> 1.11.2' # for thread support to speed up uploads, careful not to drain the server resources

# Background jobs
gem 'delayed_job_active_record', '~> 4.1.1'
gem 'daemons', '~> 1.2.4'

# Secrets
gem 'figaro', '~> 1.1.1' # manage development credentials

# API build
gem 'grape', '~> 0.19.2'
gem 'grape-active_model_serializers', '~> 1.5.1'
gem 'active_model_serializers', "~> 0.10.0"
gem 'api-pagination', '~> 4.5.2'
gem 'rack-cors', '~> 0.4.1', :require => 'rack/cors'

# User authentication and authorization
gem 'devise', '~> 4.3.0'
gem 'omniauth-facebook', '~> 4.0.0'
gem 'pundit', '~> 1.1.0' # Permissions

# Faster JSON handling
gem 'oj', '~> 3.0.8'
# gem 'oj_mimic_json', '~> 1.0.1' # has compatibility issue with current version of activeadmin, deactivated for now

# Elasticsearch support
gem 'searchkick', '~> 2.3.0'
gem 'typhoeus', '~> 1.1.2' # persistent HTTP connections for better performance in Elasticsearch
gem 'kaminari', '~> 1.0.0' # pagination support
gem 'jquery-infinite-pages', '~> 0.2.0' # infinite scrolling support

# OCR support
# gem tesseract

# CSS + JS Assets
gem 'bower-rails', '~> 0.11.0'
gem 'bootstrap-sass', '~> 3.3.7'

# Access controllar variables in JS
gem 'gon', '~> 6.1.0'
# Meta Tags
gem 'meta-tags', '~> 2.4.1'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.1'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Capistrano for deployment
  #gem 'capistrano', '~> 3.8', '>= 3.8.0'
  #gem 'capistrano-rails', '~> 1.2'
  #gem 'capistrano-passenger', '~> 0.2.0' # passenger support
  #gem 'capistrano-rbenv', '~> 2.1' # rbenv support
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
