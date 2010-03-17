# rails tryout -m fashioned.rb --skip-activerecord

app = File.expand_path(File.join(File.dirname(__FILE__))).split('/').last

# This uses Edge Rails for now
file 'Gemfile', <<-GEMS
source 'http://rubygems.org'
gem "rails", :git => "git://github.com/rails/rails.git"
gem "mongo_ext"
gem "mongo_mapper"
gem "haml"
gem "compass", "0.10.0.rc1"
gem "rails3-generators"

group :test do
  gem "rspec-rails", ">= 2.0.0.beta.4"
  gem "webrat"
  gem 'database_cleaner'
  gem 'cucumber-rails'
end
GEMS

# Bundle 
run 'bundle install'

# MongoDB Initializer taken from MongoDB docs.
initializer 'mongodb.rb', <<-CODE
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "#{app}-\#{Rails.env}"

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect_to_master if forked
   end
end
CODE

# Overwrites database.yml
file 'config/database.yml', <<-CODE
# Using MongoDB
CODE

# Initialize HAML
run 'haml --rails .'

# Initialize testing suite
run 'script/rails g rspec:install'
run 'script/rails g cucumber:skeleton --rspec --webrat'

file 'config/cucumber.yml', <<-CUCUMBER
default: --format pretty --color
wip: --tags @wip:3 --wip features
CUCUMBER

run "curl -L http://github.com/rizwanreza/fashioned/raw/master/rstakeout.rb > script/rstakeout"
run "curl -L http://github.com/rizwanreza/fashioned/raw/master/cucumber-stakeout.sh > script/cucumber-stakeout"
run "curl -L http://github.com/rizwanreza/fashioned/raw/master/rspec-stakeout.sh > rspec-stakeout"

run "chmod +x script/*"

capify!

# Remove default javascript files, download jQuery 1.4.2 and initialize jQuery in application.js
run "rm public/javascripts/*.js"
run "curl -L http://code.jquery.com/jquery-1.4.2.min.js > public/javascripts/jquery-1.4.2.min.js"
run "curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js"

file 'public/javascripts/application.js',
%q|jQuery(function () {
  
});
|

config = <<-CONFIG

    config.generators do |g|
      g.orm             :mongo_mapper
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => true
    end
CONFIG

inject_into_file 'config/application.rb', "#{config}", {:after => "# end", :verbose => true}

# Remove index.html and rails.png
run "rm public/index.html"
run "rm public/images/rails.png"

# Remove test directory since we're not using test/unit
run "rm -rf test"

readme = <<-README
===============================================================================

   Phew! All work done.

   * Your application in #{app} is configured to use Mongomapper, HAML/SASS, 
   Compass, rSpec, Cucumber, Webrat and jQuery.

   * You can see all the included generators by 'rails generate'.

   * The MongoDB databases are prefixed by your application's name.

   * jQuery 1.4.2 and its Rails helpers are in public/javascripts.

   * You can now instantiate Compass by running its fine generator:

     bundle exec compass --rails . -f blueprint

   * If you haven't used the option --skip-activerecord while generating this 
     application, you might just want to do that or paste the following in
     application.rb:

     # require 'rails/all'
     # require "active_record/railtie"
     require "action_controller/railtie"
     require "action_mailer/railtie"
     require "active_resource/railtie"
     require "rails/test_unit/railtie"

   Get coding!

===============================================================================
README

puts readme