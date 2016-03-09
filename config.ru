require 'rack/protection'
require './app/swish'

use Rack::Session::Cookie, secret: ENV['SESSION_SECRET'] || 'placeholder'
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

$stdout.sync = true

run Swish.new
