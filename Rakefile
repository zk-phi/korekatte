require 'sinatra/activerecord/rake'
require_relative 'app/db'

namespace :db do
  task :load_config do
    require './app/swish'
  end
end

# require 'csv'
# require_relative 'app/models/bookmark'

# CSV_PATH = 'swish.csv'

# namespace :util do
#   desc 'bookmark to csv'          # description
#   task :export_csv do |t|
#     DB.connect(ENV['RACK_ENV'] || 'development')
#     CSV.open(CSV_PATH, 'wb') do |csv|
#       csv << Bookmark.attribute_names
#       Bookmark.find_each do |bookmark|
#         csv << bookmark.attributes.values
#       end
#     end
#     DB.close
#     puts "generate csv => #{CSV_PATH}"
#   end
# end
