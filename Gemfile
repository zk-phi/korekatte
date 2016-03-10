source 'https://rubygems.org'

gem 'sinatra'                   # the framework
gem 'activerecord'              # O/R mapper
gem 'sinatra-activerecord'      # sinatra extension for activerecord
gem 'rake'                      # utility
gem 'bcrypt'                    # password encryption
gem 'rack-ssl'                  # force SSL (https)

# DB driver
group :production do
  gem 'pg'
end
group :development do
  gem 'sqlite3', '~> 1.3.0'
end
